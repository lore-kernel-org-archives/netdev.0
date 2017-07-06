From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH net-next 1/3] net: ethtool: add support for forward
 error correction modes
Date: Thu, 6 Jul 2017 21:06:09 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B62650492000@ORSMSX102.amr.corp.intel.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628134139.GB12559@lunn.ch>
        <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
        <20170628180008.42059797@cakuba.netronome.com>
        <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706120214.6076be46@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dustin Byford <dustin@cumulusnetworks.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>,
        "olson@cumulusnetworks.com" <olson@cumulusnetworks.com>,
        Manoj Malviya <manojmalviya@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>,
        "yuval.mintz@qlogic.com" <yuval.mintz@qlogic.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Jakub Kicinski <kubakici@wp.pl>, Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38579 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751936AbdGFVGM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 17:06:12 -0400
In-Reply-To: <20170706120214.6076be46@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Jakub Kicinski
> Sent: Thursday, July 06, 2017 12:02 PM
> To: Casey Leedom <leedom@chelsio.com>
> Cc: Dustin Byford <dustin@cumulusnetworks.com>; Andrew Lunn
> <andrew@lunn.ch>; Roopa Prabhu <roopa@cumulusnetworks.com>;
> davem@davemloft.net; linville@tuxdriver.com; netdev@vger.kernel.org;
> vidya.chowdary@gmail.com; olson@cumulusnetworks.com; Manoj Malviya
> <manojmalviya@chelsio.com>; Santosh Rastapur <santosh@chelsio.com>;
> yuval.mintz@qlogic.com; odedw@mellanox.com; ariela@mellanox.com;
> galp@mellanox.com; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
> correction modes
> 
[..]
> > In our discussions of the above, we decided that we should err in the
> > direction of the absolutely simplest abstraction model, even when
> > that might result in a failure to establish a link.  Our feeling was
> > that doing anything else would result in endless user confusion.
> > Basically, if it takes longer than a simple paragraph to explain,
> > you're probably doing the wrong thing.  So, we decided that if a user
> > sets up a particular FEC setting, we keep that regardless of conflict
> > with different Transceiver Modules.  (But flag such issues in the
> > System Log in order to try to give the user a chance to understand
> > what the new cable they plugged in wasn't working.)
> 
> IMHO if something gets replugged all the settings should be reset.
> I feel that it's not entirely unlike replugging a USB adapter.  Perhaps
> we should introduce some (devlink) notifications for SFP module events
> so userspace can apply whatever static user config it has?

This is an interesting dichotomy and we've been trying to resolve it as well as the module variations and permutations grow.  I agree with Casey that this bleeds into link speeds as well.  

I can see both perspectives:  try to apply to user settings even if they do something dumb and notify if things go bad; and, swapping modules should reset.  Notifications of some kind would help the devices manage this.  We tend to go with timers today.

Carolyn

Carolyn Wyborny 
Linux Development 
Networking Division 
Intel Corporation 
