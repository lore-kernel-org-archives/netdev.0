From: dean gaudet <dean@arctic.org>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 12:37:33 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609271236230.2299@twinlark.arctic.org>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com>
 <Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org> <451AD1D6.4030708@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	dhinds@pcmcia.sourceforge.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.7.145.18]:25759 "EHLO
	twinlark.arctic.org") by vger.kernel.org with ESMTP
	id S1030704AbWI0Thd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 15:37:33 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <451AD1D6.4030708@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2006, Auke Kok wrote:

> dean gaudet wrote:
> > On Tue, 26 Sep 2006, Jeff Garzik wrote:
> > 
> > > Stephen Hemminger wrote:
> > > > The mii-tool utility seems to be abandoned and unmaintained?
> > > > 
> > > > Here is a version that does standard 1000baseT support.
> > > > 	http://developer.osdl.org/shemminger/prototypes/mii-tool.tar.bz2
> > > Not really.  I would rather leave it as-is, and deprecate it in favor of
> > > ethtool.
> > 
> > is there some ethtool (version 5) option i'm missing that will give a nice
> > concise link negotation state report like mii-tool does?
> 
> how about `ethtool ethX` ? It doesn't report what happened during negotiotion
> but it shows status and advertised/autonegotiated/supported modes

well now don't i feel dumb, i didn't even try running it without an 
option.  yes must be the lack of caffeine.  thanks.

-dean
