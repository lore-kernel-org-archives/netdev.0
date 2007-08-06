From: Pavel Machek <pavel@ucw.cz>
Subject: Re: e1000 doesn't resume properly from standby (2.6.23-rc2)
Date: Mon, 6 Aug 2007 12:44:56 +0200
Message-ID: <20070806104456.GA1901@elf.ucw.cz>
References: <46B58FB4.6050207@simon.arlott.org.uk> <46B68F08.60106@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Arlott <simon@fire.lp0.eu>,
	linux-pm@lists.linux-foundation.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:49324 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762874AbXHFLGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 07:06:49 -0400
Content-Disposition: inline
In-Reply-To: <46B68F08.60106@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> >00:0a.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet 
> >Controller (Copper) (rev 01)
> >        Subsystem: Intel Corp.: Unknown device 1012
> >        Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 5
> >        Memory at e3020000 (64-bit, non-prefetchable) [size=128K]
> >        I/O ports at b000 [size=64]
> >        Capabilities: [dc] Power Management version 2
> >        Capabilities: [e4] PCI-X non-bridge device.
> >        Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 
> >        Enable-
> >
> >00:0a.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet 
> >Controller (Copper) (rev 01)
> >        Subsystem: Intel Corp.: Unknown device 1012
> >        Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 12
> >        Memory at e3000000 (64-bit, non-prefetchable) [size=128K]
> >        I/O ports at b400 [size=64]
> >        Capabilities: [dc] Power Management version 2
> >        Capabilities: [e4] PCI-X non-bridge device.
> >        Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 
> >        Enable-
> >
> >[  950.132046] Stopping tasks ... done.
> >[  950.459794] Suspending console(s)
> >[  951.776277] pnp: Device 00:0c disabled.
> >[  951.776673] pnp: Device 00:0a disabled.
> >[  951.776984] pnp: Device 00:09 disabled.
> >[  951.777306] pnp: Device 00:08 disabled.
> >[  951.777786] ACPI: PCI interrupt for device 0000:00:11.5 disabled
> >[  951.995359] ACPI: PCI interrupt for device 0000:00:11.3 disabled
> >[  952.006094] ACPI: PCI interrupt for device 0000:00:11.2 disabled
> >[  952.022243] ACPI handle has no context!
> >[  952.033068] ACPI: PCI interrupt for device 0000:00:0c.2 disabled
> >[  952.044086] ACPI: PCI interrupt for device 0000:00:0c.1 disabled
> >[  952.055083] ACPI: PCI interrupt for device 0000:00:0c.0 disabled
> >[  952.282211] ACPI: PCI interrupt for device 0000:00:0a.1 disabled
> >[  952.282221] ACPI handle has no context!
> >[  952.537474] ACPI: PCI interrupt for device 0000:00:0a.0 disabled
> >[  952.537495] ACPI handle has no context!
> >
> >[  956.857085] Back to C!

Are you sure that is standby? Looks like suspend-to-RAM to me.

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
