From: Sergey Vlasov <vsu@altlinux.ru>
Subject: Re: D-Link DFE-580TX 4 port Server Adapter problem: only 2 of 4
 ports
Date: Fri, 4 May 2007 21:32:11 +0400
Message-ID: <20070504213211.02d8e9bd.vsu@altlinux.ru>
References: <200704130348.22852.dap@mail.index.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__4_May_2007_21_32_11_+0400_6r6dDwZJozlwzJC3"
Cc: "Sergey Y. Afonin" <asy@altlinux.ru>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pallai Roland <dap@mail.index.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.altlinux.org ([62.118.250.235]:1576 "EHLO
	master.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031461AbXEDSCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 14:02:33 -0400
In-Reply-To: <200704130348.22852.dap@mail.index.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__4_May_2007_21_32_11_+0400_6r6dDwZJozlwzJC3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Fri, 13 Apr 2007 03:48:22 +0200 Pallai Roland wrote:

>  I've got a problem with my DFE-580TX cards when I installed thoose into
> a new server box. One card has been worked before in a test box,
> it's sure, here is a dmesg snippet when everything was OK:
>
> Apr  3 22:10:38 cyrax kernel: sundance.c:v1.2 11-Sep-2006  Written by Donald Becker
> Apr  3 22:10:38 cyrax kernel:   http://www.scyld.com/network/sundance.html
> Apr  3 22:10:38 cyrax kernel: ACPI: PCI Interrupt 0000:02:04.0[A] -> GSI 21 (level, low) -> IRQ 23
> Apr  3 22:10:38 cyrax kernel: eth2: D-Link DFE-580TX 4 port Server Adapter at 0001a800, 00:0d:88:cc:da:dc, IRQ 23.
> Apr  3 22:10:38 cyrax kernel: eth2: MII PHY found at address 1, status 0x7809 advertising 01e1.
> Apr  3 22:10:38 cyrax kernel: ACPI: PCI Interrupt 0000:02:05.0[A] -> GSI 22 (level, low) -> IRQ 18
> Apr  3 22:10:39 cyrax kernel: eth3: D-Link DFE-580TX 4 port Server Adapter at 0001b000, 00:0d:88:cc:da:dd, IRQ 18.
> Apr  3 22:10:39 cyrax kernel: eth3: MII PHY found at address 1, status 0x7809 advertising 01e1.
> Apr  3 22:10:39 cyrax kernel: ACPI: PCI Interrupt 0000:02:06.0[A] -> GSI 23 (level, low) -> IRQ 19
> Apr  3 22:10:39 cyrax kernel: eth4: D-Link DFE-580TX 4 port Server Adapter at 0001b400, 00:0d:88:cc:da:de, IRQ 19.
> Apr  3 22:10:39 cyrax kernel: eth4: MII PHY found at address 1, status 0x7809 advertising 01e1.
> Apr  3 22:10:39 cyrax kernel: ACPI: PCI Interrupt 0000:02:07.0[A] -> GSI 20 (level, low) -> IRQ 20
> Apr  3 22:10:39 cyrax kernel: eth5: D-Link DFE-580TX 4 port Server Adapter at 0001b800, 00:0d:88:cc:da:df, IRQ 20.
> Apr  3 22:10:39 cyrax kernel: eth5: MII PHY found at address 1, status 0x7809 advertising 01e1.
>
>  And the current dmesg from the new box, when I've only 2 of 4 ports on each card:
>
> sundance.c:v1.2 11-Sep-2006  Written by Donald Becker
>   http://www.scyld.com/network/sundance.html
> ACPI: PCI Interrupt 0000:05:04.0[A] -> GSI 21 (level, low) -> IRQ 22
> eth2: D-Link DFE-580TX 4 port Server Adapter at 00012180, 00:00:00:00:00:00, IRQ 22.
> eth2: No MII transceiver found, aborting.  ASIC status ffffffff
> ACPI: PCI Interrupt 0000:05:05.0[A] -> GSI 22 (level, low) -> IRQ 23
> eth2: D-Link DFE-580TX 4 port Server Adapter at 00012100, 00:00:00:00:00:00, IRQ 23.
> eth2: No MII transceiver found, aborting.  ASIC status ffffffff
> ACPI: PCI Interrupt 0000:05:06.0[A] -> GSI 23 (level, low) -> IRQ 19
> eth2: D-Link DFE-580TX 4 port Server Adapter at 00012080, 00:0d:88:cc:da:ee, IRQ 19.
> eth2: MII PHY found at address 1, status 0x7809 advertising 01e1.
> ACPI: PCI Interrupt 0000:05:07.0[A] -> GSI 20 (level, low) -> IRQ 21
> eth3: D-Link DFE-580TX 4 port Server Adapter at 00012000, 00:0d:88:cc:da:ef, IRQ 21.
> eth3: MII PHY found at address 1, status 0x7809 advertising 01e1.
> ACPI: PCI Interrupt 0000:06:04.0[A] -> GSI 22 (level, low) -> IRQ 23
> eth4: D-Link DFE-580TX 4 port Server Adapter at 00011180, 00:00:00:00:00:00, IRQ 23.
> eth4: No MII transceiver found, aborting.  ASIC status ffffffff
> ACPI: PCI Interrupt 0000:06:05.0[A] -> GSI 21 (level, low) -> IRQ 22
> eth4: D-Link DFE-580TX 4 port Server Adapter at 00011100, 00:00:00:00:00:00, IRQ 22.
> eth4: No MII transceiver found, aborting.  ASIC status ffffffff
> ACPI: PCI Interrupt 0000:06:06.0[A] -> GSI 20 (level, low) -> IRQ 21
> eth4: D-Link DFE-580TX 4 port Server Adapter at 00011080, 00:0d:88:cc:da:de, IRQ 21.
> eth4: MII PHY found at address 1, status 0x7809 advertising 01e1.
> ACPI: PCI Interrupt 0000:06:07.0[A] -> GSI 23 (level, low) -> IRQ 19
> eth5: D-Link DFE-580TX 4 port Server Adapter at 00011000, 00:0d:88:cc:da:df, IRQ 19.
> eth5: MII PHY found at address 1, status 0x7809 advertising 01e1.
>
>
>  Kernel version is vanilla 2.6.20.3, Sundance MMIO disabled in the
>  config. I can send lspci, full dmesg, .config if anyone interested
>  in. Maybe it's a BIOS problem?  What should I try?

Sergey Afonin (cc'd) ran into the same problem when trying to use the
DFE-580TX card on a new machine with the Intel 945G chipset (I don't
have exact motherboard info - PCI subsystem ID matches Intel D945GTP)
and 2.6.18-based x86_64 kernel.

ALT Linux Bugzilla entry (sorry - it's in Russian):
https://bugzilla.altlinux.org/show_bug.cgi?id=11687

Full dmesg output:	https://bugzilla.altlinux.org/attachment.cgi?id=1940
lspci -vvxxx output:	https://bugzilla.altlinux.org/attachment.cgi?id=1942

I have tracked down this problem to a bad I/O base address assignment
for network chips.  As you may find from the lspci -vvxxx info, the
following addresses were assigned to region 0 of these chips:

  05:04.0 - 0x1180
  05:05.0 - 0x1100
  05:06.0 - 0x1080
  05:07.0 - 0x1000

Chips at 0x1000 and 0x1080 work fine; however, chips at 0x1100 and
0x1180 are not reachable, because the PCI-PCI bridge 04:00.0 has the
NoISA bit in the BridgeCtl register set, and these addresses are being
treated as ISA port aliases and not forwarded to the internal PCI bus of
the card.  (The bridge at 00:1e.0 also has NoISA set, but this is not a
problem, because that bridge is transparent.)  Turning off the NoISA bit
with "setpci -s 04:00.0 3e.b=00" makes all Ethernet ports work.

For comparison, the lspci -vvxxx output from an older machine, where
this card works: https://bugzilla.altlinux.org/attachment.cgi?id=1944
In this case the I/O port addresses for network chips are assigned
correctly: 0x9000, 0x9400, 0x9800, 0x9c00, and all ports work.

The problem looks like a BIOS bug - apparently the PCI config set up by
the BIOS is bogus.  However, can Linux at least warn, or (even better)
apply some workaround in such cases?

--Signature=_Fri__4_May_2007_21_32_11_+0400_6r6dDwZJozlwzJC3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.1 (GNU/Linux)

iD8DBQFGO24mW82GfkQfsqIRAqPeAJ40AqGQHAadr7PRRUXGf5i8pkPfiACfehlu
5SNK3ExyUcD2xXAJlrUE8ew=
=A4U6
-----END PGP SIGNATURE-----

--Signature=_Fri__4_May_2007_21_32_11_+0400_6r6dDwZJozlwzJC3--
