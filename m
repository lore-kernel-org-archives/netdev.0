From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: mii-tool gigabit support.
Date: Thu, 28 Sep 2006 13:10:07 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0609281216470.3949@blysk.ds.pg.gda.pl>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com>
 <20060926150947.3d538547@freekitty> <451A7603.1030204@roinet.com>
 <451AAFFE.2020607@hp.com> <451AB9CB.6010906@intel.com> <451ABB73.1050606@hp.com>
 <Pine.LNX.4.64N.0609271858440.7657@blysk.ds.pg.gda.pl> <451AC630.2030509@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>, David Acker <dacker@roinet.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:19722 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1751866AbWI1MKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 08:10:14 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <451AC630.2030509@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2006, Auke Kok wrote:

> > Older equipment, which may still be in use here and there, allowed
> > full-duplex operation, but no auto-negotiation.  The duplex setting was
> > either fixed or selectable in a system-specific manner.  In such a case you
> > certainly want your modern other end to be forced to full-duplex, but still
> > let it detect the link speed, so that you do not have to do reconfiguration
> > whenever you move a link between a 10base-T and a 100base-Tx port.
> 
> in this case the new addition to ethtool will not help as it only changes the
> modes that the NIC will advertise. In this specific case you will need to turn
> of advertising/autonegotiation and force a speed/duplex pair anyway.

 My whole point is to keep the speed negotiation enabled.  If you force a 
given speed and the partner only supports a different one, you will get no 
link.

> Advertising all half-duplex modes to a partner that does not do
> autonegotiation is (by spec I think) an unsupported configuration (i.e.
> undetermined behaviour).

 Yes, but more reasonable PHYs will autosense the link speed if allowed 
to, even if the partner is not capable of negotiating.  It is useful, so 
why should we limit people so that they cannot do it?

 And as I wrote, it is not half-duplex operation that is problematic as it 
is the default if the partner does not negotiate anyway.

  Maciej
