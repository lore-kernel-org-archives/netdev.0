From: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Mon, 25 Jul 2011 12:36:44 +0200
Message-ID: <20110725103643.GA11135@colin.search.kasperd.net>
References: <20110724195831.GA8718@colin.search.kasperd.net> <20110724201626.GB24418@zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: =?iso-8859-1?Q?Fran=E7ois?= romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nfitmail.nfit.au.dk ([130.225.31.129]:32319 "EHLO
	smtp.nfit.au.dk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751673Ab1GYKqI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 06:46:08 -0400
Content-Disposition: inline
In-Reply-To: <20110724201626.GB24418@zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/07/11 22.16, Fran=E7ois romieu wrote:
> The Sun, Jul 24, 2011 at 09:58:31PM +0200, Kasper Dupont wrote :
> [...]
> > Any idea how to fix this?
>=20
> Apply 1519e57fe81c14bb8fa4855579f19264d1ef63b4 as well and
> eventually f60ac8e7ab7cbb413a0131d5665b053f9f386526.
>=20
> Please send r8169 related lines from dmesg, especially the XID
> one and Cc: netdev.

These are the relevant lines from dmesg:

[    1.045727] pata_sch 0000:00:1f.1: setting latency timer to 64
[    1.045946] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.046061] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> =
IRQ 16
[    1.046201] r8169 0000:02:00.0: setting latency timer to 64
[    1.046257]   alloc irq_desc for 24 on node -1
[    1.046263]   alloc kstat_irqs on node -1
[    1.046284] r8169 0000:02:00.0: irq 24 for MSI/MSI-X
[    1.048097] eth0: RTL8168c/8111c at 0xf8076000, 00:01:c0:09:a1:25, X=
ID 1c4000c0 IRQ 24
[    1.051517] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.051631] r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> =
IRQ 17
[    1.051764] r8169 0000:03:00.0: setting latency timer to 64
[    1.051820]   alloc irq_desc for 25 on node -1
[    1.051825]   alloc kstat_irqs on node -1
[    1.051847] r8169 0000:03:00.0: irq 25 for MSI/MSI-X
[    1.053159] usb 1-7: new high speed USB device using ehci_hcd and ad=
dress 5
[    1.056574] vga16fb: initializing
[    1.056584] vga16fb: mapped to 0xc00a0000
[    1.056819] fb0: VGA16 VGA frame buffer device
[    1.070138] scsi0 : pata_sch
[    1.078253] scsi1 : pata_sch
[    1.079216] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1800=
 irq 14
[    1.079312] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1808=
 irq 15
[    1.082178] eth1: RTL8168c/8111c at 0xf8096000, 00:01:c0:09:a1:26, X=
ID 1c4000c0 IRQ 25
[    1.205643] usb 1-7: configuration #1 chosen from 1 choice

It works on 2.6.32.32 it crashes on 2.6.32.33. I tried to
take 2.6.32.43 and apply 1519e57fe81c14bb8fa4855579f19264d1ef63b4,
that did not help. 2.6.32.43 crashes with and without that patch.

--=20
Kasper Dupont -- Rigtige m=E6nd skriver deres egne backupprogrammer
#define _(_)"d.%.4s%."_"2s" /* This is my email address */
char*_=3D"@2kaspner"_()"%03"_("4s%.")"t\n";printf(_+11,_+6,_,11,_+2,_+7=
,_+6);
