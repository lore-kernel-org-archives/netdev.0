From: Dave Olson <olson@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 6 Jul 2017 18:38:31 -0700
Message-ID: <20170707013831.GB26681@cumulusnetworks.com>
References: <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
 <20170628180008.42059797@cakuba.netronome.com>
 <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706223324.GA24237@lunn.ch>
 <MWHPR12MB1600B8ECA4222A062CDC71C0C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706231550.GC24237@lunn.ch>
 <MWHPR12MB16009D656DD4408DE4429274C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170707005601.GG8810@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Casey Leedom <leedom@chelsio.com>, Jakub Kicinski <kubakici@wp.pl>,
        Dustin Byford <dustin@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>,
        Manoj Malviya <manojmalviya@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>,
        "yuval.mintz@qlogic.com" <yuval.mintz@qlogic.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33539 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753177AbdGGBif (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 21:38:35 -0400
Received: by mail-pf0-f172.google.com with SMTP id e7so9294682pfk.0
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 18:38:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170707005601.GG8810@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> wrote:
> And when we are talking about SFP modules, we are not talking about
> somebody who can just about boiling an egg and put bread in the
> toaster.
> 
> Anybody using these SFP modules knows a lot about networking, is a
> power user, and probably does not rely on plug and pray.

We have strong evidence that this is not the case with many system and
network admins...

Casey is right; the simplest mental model for end-users that can be
made to work reasonably is the best answer.

And from a user perspective, that means (to me, from watching customer
cases), keeping the customers settings if at all possible, and spitting
out warnings and errors when it can't work.

As Casey keeps saying, there is no model that will work in all (or even
most) of the interesting use cases, where cables can change with some
frequency, especially when there are lots of ports (as on switches).

Dave Olson
olson@cumulusnetworks.com
