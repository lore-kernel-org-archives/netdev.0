From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 19:05:25 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0609271858440.7657@blysk.ds.pg.gda.pl>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com>
 <20060926150947.3d538547@freekitty> <451A7603.1030204@roinet.com>
 <451AAFFE.2020607@hp.com> <451AB9CB.6010906@intel.com> <451ABB73.1050606@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	David Acker <dacker@roinet.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:28165 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1030476AbWI0SF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 14:05:26 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <451ABB73.1050606@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2006, Rick Jones wrote:

> > Another scenario: forcing the NIC to negotiate only full-duplex speeds. Not
> > only fun if you try it against a hub, but possibly useful.
[...]
> I'm just worried (as in Fear Uncertainty and Doubt) that having people set the
> allowed things to negotiate isn't really any more robust than stright-up
> hardcodes and perpetuates the (IMO) myth that one shouldn't autoneg on general
> principle.

 Older equipment, which may still be in use here and there, allowed 
full-duplex operation, but no auto-negotiation.  The duplex setting was 
either fixed or selectable in a system-specific manner.  In such a case 
you certainly want your modern other end to be forced to full-duplex, but 
still let it detect the link speed, so that you do not have to do 
reconfiguration whenever you move a link between a 10base-T and a 
100base-Tx port.

  Maciej
