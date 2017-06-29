From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 29 Jun 2017 15:30:12 +0200
Message-ID: <20170629133012.GB9244@lunn.ch>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <20170627032239.05cdc462@cakuba.netronome.com>
 <20170628134139.GB12559@lunn.ch>
 <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>,
        Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
        linville@tuxdriver.com, netdev@vger.kernel.org,
        vidya.chowdary@gmail.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        galp@mellanox.com, jeffrey.t.kirsher@intel.com
To: Dustin Byford <dustin@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39030 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752684AbdF2NaV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 09:30:21 -0400
Content-Disposition: inline
In-Reply-To: <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 02:47:51PM -0700, Dustin Byford wrote:
> Hi Andrew,
> 
> On Wed Jun 28 15:41, Andrew Lunn wrote:
> > On Tue, Jun 27, 2017 at 03:22:39AM -0700, Jakub Kicinski wrote:
> > > On Sat, 24 Jun 2017 12:19:43 -0700, Roopa Prabhu wrote:
> > > > Encoding: Types of encoding
> > > > Off    :  Turning off any encoding
> > > > RS     :  enforcing RS-FEC encoding on supported speeds
> > > > BaseR  :  enforcing Base R encoding on supported speeds
> > > > Auto   :  IEEE defaults for the speed/medium combination
> > > 
> > > Just to be sure - does auto mean autonegotiate as defined by IEEE or
> > > some presets?
> > 
> > I don't know this field very well. Is this confusion likely to happen
> > a lot? Is there a better name for Auto which is less likely to be
> > confused?
> 
> You're not the first, or the second to ask that question.  I agree it
> could use clarification.
> 
> I always read auto in this context as automatic rather than autoneg.

Hi Dustin

Automatic would be better.

Thanks
	Andrew
