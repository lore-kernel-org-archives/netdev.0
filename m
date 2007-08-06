From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 doesn't resume properly from standby (2.6.23-rc2)
Date: Sun, 05 Aug 2007 20:01:28 -0700
Message-ID: <46B68F08.60106@intel.com>
References: <46B58FB4.6050207@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761969AbXHFDBt@vger.kernel.org>
In-Reply-To: <46B58FB4.6050207@simon.arlott.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Arlott wrote:
> 00:0a.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (Copper) (rev 01)
>         Subsystem: Intel Corp.: Unknown device 1012
>         Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 5
>         Memory at e3020000 (64-bit, non-prefetchable) [size=128K]
>         I/O ports at b000 [size=64]
>         Capabilities: [dc] Power Management version 2
>         Capabilities: [e4] PCI-X non-bridge device.
>         Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
> 
> 00:0a.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (Copper) (rev 01)
>         Subsystem: Intel Corp.: Unknown device 1012
>         Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 12
>         Memory at e3000000 (64-bit, non-prefetchable) [size=128K]
>         I/O ports at b400 [size=64]
>         Capabilities: [dc] Power Management version 2
>         Capabilities: [e4] PCI-X non-bridge device.
>         Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
> 
> [  950.132046] Stopping tasks ... done.
> [  950.459794] Suspending console(s)
> [  951.776277] pnp: Device 00:0c disabled.
> [  951.776673] pnp: Device 00:0a disabled.
> [  951.776984] pnp: Device 00:09 disabled.
> [  951.777306] pnp: Device 00:08 disabled.
> [  951.777786] ACPI: PCI interrupt for device 0000:00:11.5 disabled
> [  951.995359] ACPI: PCI interrupt for device 0000:00:11.3 disabled
> [  952.006094] ACPI: PCI interrupt for device 0000:00:11.2 disabled
> [  952.022243] ACPI handle has no context!
> [  952.033068] ACPI: PCI interrupt for device 0000:00:0c.2 disabled
> [  952.044086] ACPI: PCI interrupt for device 0000:00:0c.1 disabled
> [  952.055083] ACPI: PCI interrupt for device 0000:00:0c.0 disabled
> [  952.282211] ACPI: PCI interrupt for device 0000:00:0a.1 disabled
> [  952.282221] ACPI handle has no context!
> [  952.537474] ACPI: PCI interrupt for device 0000:00:0a.0 disabled
> [  952.537495] ACPI handle has no context!
> 
> [  956.857085] Back to C!
> [  957.295035] ACPI: Unable to turn cooling device [b18d0e00] 'off'
> [  957.521400] PCI: Setting latency timer of device 0000:00:01.0 to 64
> [  957.521478] ACPI: PCI Interrupt 0000:00:09.0[A] -> Link [LNKB] -> GSI 11 (level, low) -> IRQ 11
> [  957.532256] PM: Writing back config space on device 0000:00:0a.0 at offset f (was ff0100, writing ff0105)
> [  957.532277] PM: Writing back config space on device 0000:00:0a.0 at offset 8 (was 1, writing b001)
> [  957.532291] PM: Writing back config space on device 0000:00:0a.0 at offset 4 (was 4, writing e3020004)
> [  957.532299] PM: Writing back config space on device 0000:00:0a.0 at offset 3 (was 800000, writing 802008)
> [  957.532309] PM: Writing back config space on device 0000:00:0a.0 at offset 1 (was 2300000, writing 2300007)
> [  957.532339] ACPI: PCI Interrupt 0000:00:0a.0[A] -> Link [LNKC] -> GSI 5 (level, low) -> IRQ 5
> [  957.567251] PM: Writing back config space on device 0000:00:0a.1 at offset f (was ff0200, writing ff020c)
> [  957.567275] PM: Writing back config space on device 0000:00:0a.1 at offset 8 (was 1, writing b401)
> [  957.567290] PM: Writing back config space on device 0000:00:0a.1 at offset 4 (was 4, writing e3000004)
> [  957.567298] PM: Writing back config space on device 0000:00:0a.1 at offset 3 (was 800000, writing 802008)
> [  957.567308] PM: Writing back config space on device 0000:00:0a.1 at offset 1 (was 2300000, writing 2300007)
> [  957.567346] ACPI: PCI Interrupt 0000:00:0a.1[B] -> Link [LNKD] -> GSI 12 (level, low) -> IRQ 12
> [  957.589975] ACPI: PCI Interrupt 0000:00:0b.0[A] -> Link [LNKD] -> GSI 12 (level, low) -> IRQ 12
> [  957.600217] ACPI: PCI Interrupt 0000:00:0c.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
> [  957.611230] ACPI: PCI Interrupt 0000:00:0c.1[B] -> Link [LNKB] -> GSI 11 (level, low) -> IRQ 11
> [  957.838282] ACPI: PCI Interrupt 0000:00:0c.2[C] -> Link [LNKC] -> GSI 5 (level, low) -> IRQ 5
> [  957.902166] ohci1394: fw-host0: OHCI-1394 1.0 (PCI): IRQ=[11]  MMIO=[e3046000-e30467ff]  Max Packet=[512]  IR/IT contexts=[4/8]
> [  957.911656] ACPI: PCI Interrupt 0000:00:11.1[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
> [  957.911666] PCI: VIA VLink IRQ fixup for 0000:00:11.1, from 255 to 11
> [  957.922034] ACPI: PCI Interrupt 0000:00:11.2[D] -> Link [LNKD] -> GSI 12 (level, low) -> IRQ 12
> [  957.933028] ACPI: PCI Interrupt 0000:00:11.3[D] -> Link [LNKD] -> GSI 12 (level, low) -> IRQ 12
> [  957.944076] ACPI: PCI Interrupt 0000:00:11.5[C] -> Link [LNKC] -> GSI 5 (level, low) -> IRQ 5
> [  957.944091] PCI: Setting latency timer of device 0000:00:11.5 to 64
> [  957.946061] ACPI: PCI Interrupt 0000:01:00.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
> [  957.947464] pnp: Device 00:08 activated.
> [  957.948724] pnp: Device 00:09 activated.
> [  957.950635] pnp: Device 00:0a activated.
> [  957.950664] pnp: Failed to activate device 00:0b.
> [  957.951942] pnp: Device 00:0c activated.
> [  959.883939] e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> [  961.866287] hde: selected mode 0x45
> [  965.310493] hdg: selected mode 0x45
> [  965.316152] hdh: selected mode 0x42
> [  969.135523] hda: selected mode 0x46
> [  973.454631] hdb: selected mode 0x45
> [  973.457179] hdc: selected mode 0x44
> [  973.459550] hdd: selected mode 0x42
> [  973.950474] Restarting tasks ... done.
> [  974.261357] agpgart: Found an AGP 2.0 compliant device at 0000:00:00.0.
> [  974.262099] agpgart: Putting AGP V2 device at 0000:00:00.0 into 4x mode
> [  974.262620] agpgart: Putting AGP V2 device at 0000:01:00.0 into 4x mode
> [  974.262894] [drm] Loading R200 Microcode
> 
> 
> eth0 now doesn't receive anything - it's transmitting ok because 
> I can receive its packets on another host. It's also still getting 
> interrupts.
> 
> If I then ifconfig eth0 down and up, or change the MTU (since 
> that resets the link on e1000), it starts working again:
> 
> [  993.926603] e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> 
> 
> There's a link up at 959.883939 too...


OK, I'll try to look into this coming week.

Can you run `ethtool -d ethX` immediately after resuming and post that output? 
it might help to know that upfront.

Thanks,

Auke
