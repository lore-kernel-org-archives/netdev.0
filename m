From: Dave Jones <davej@redhat.com>
Subject: Re: odd RTL8139 quirk.
Date: Tue, 29 Apr 2008 15:47:18 -0400
Message-ID: <20080429194718.GC21035@redhat.com>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755391AbYD2TrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 15:47:23 -0400
Content-Disposition: inline
In-Reply-To: <48177905.4000409@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 03:37:41PM -0400, Jeff Garzik wrote:
 > Dave Jones wrote:
 > > I've just been playing with a model 2 OQO, which has an RTL8139.
 > > It gets detected just fine, though it doesn't actually work..
 > > 
 > > eth0: RealTek RTL8139 at 0xf8830000, 00:00:00:00:00:00, IRQ 18
 > > eth0:  Identified 8139 chip type 'RTL-8139'
 > > 
 > > The null MAC address being one clue.  Another oddity is that
 > > ethtool reports that there's no link detected, even though there is.
 > > (Enough for it to PXE boot a kernel from at least :)
 > > 
 > > Futzing with the debug= modparam didn't yield anything extra at all.
 > > 
 > > Any clues?
 > 
 > Sounds like a broken EEPROM.

Not that it counts for much, but the NIC works fine in the vista install
that it came with.

 >  Does supplying a MAC via ifconfig prior to 'ifconfig ... up' help?

That fails spectacularly with 'eth0: PCI Bus error 0290' after I do the 'up'
Someone suggested that the PHY isn't being detected.
I don't get any of the MII messages from rtl8139_init_one()
Which is odd (to me at least) as ethtool reports MII as a supported port,
(and even has it as the 'current' port).

	Dave

-- 
http://www.codemonkey.org.uk
