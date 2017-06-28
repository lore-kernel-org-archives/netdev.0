From: Dustin Byford <dustin@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Wed, 28 Jun 2017 14:47:51 -0700
Message-ID: <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <20170627032239.05cdc462@cakuba.netronome.com>
 <20170628134139.GB12559@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>,
        Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
        linville@tuxdriver.com, netdev@vger.kernel.org,
        vidya.chowdary@gmail.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        galp@mellanox.com, jeffrey.t.kirsher@intel.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34350 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdF1Vry (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 17:47:54 -0400
Received: by mail-pg0-f46.google.com with SMTP id t186so37989381pgb.1
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 14:47:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170628134139.GB12559@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Wed Jun 28 15:41, Andrew Lunn wrote:
> On Tue, Jun 27, 2017 at 03:22:39AM -0700, Jakub Kicinski wrote:
> > On Sat, 24 Jun 2017 12:19:43 -0700, Roopa Prabhu wrote:
> > > Encoding: Types of encoding
> > > Off    :  Turning off any encoding
> > > RS     :  enforcing RS-FEC encoding on supported speeds
> > > BaseR  :  enforcing Base R encoding on supported speeds
> > > Auto   :  IEEE defaults for the speed/medium combination
> > 
> > Just to be sure - does auto mean autonegotiate as defined by IEEE or
> > some presets?
> 
> I don't know this field very well. Is this confusion likely to happen
> a lot? Is there a better name for Auto which is less likely to be
> confused?

You're not the first, or the second to ask that question.  I agree it
could use clarification.

I always read auto in this context as automatic rather than autoneg.
The best I can come up with is to perhaps fully spell out "automatic" in
the documentation and the associated uapi enums.  It's accurate, and
hopefully different enough from "autoneg" to hint people away from the
IEEE autoneg concept.

		--Dustin
