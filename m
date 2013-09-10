From: =?UTF-8?B?RnLDqWTDqXJpYyBMZXJveQ==?= <fredo@starox.org>
Subject: Re: [PATCH net 1/1] r8169: enforce RX_MULTI_EN for the 8168f.
Date: Tue, 10 Sep 2013 10:08:24 +0200
Message-ID: <522ED378.5090000@starox.org>
References: <20130907231535.GB24530@electric-eye.fr.zoreil.com> <941AC15120E247718F8B349F9B3B7422@realtek.com.tw> <20130909225050.GA2529@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	'David Miller' <davem@davemloft.net>,
	'David R' <david@unsolicited.net>,
	'nic_swsd' <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-34071.dedibox.fr ([88.191.154.35]:48285 "EHLO
	sd-34071.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898Ab3IJII2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 04:08:28 -0400
In-Reply-To: <20130909225050.GA2529@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/09/2013 00:50, Francois Romieu a =C3=A9crit :
> hayeswang <hayeswang@realtek.com> :
> [...]
> > I don't have any issue reported about the fetching numbers, so I ha=
ve no
> > idea about why it could fix you problem.
>
> Thanks Hayes.
>
> Fr=C3=A9d=C3=A9ric, David (R not M), do your systems include some Mar=
vell SATA controller ?
>

I have an amd one :

    [fredo:~] $ lspci  | grep SATA
    00:11.0 SATA controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] (rev 40)

But I know I have sata ncq errors and stability problems with kernels >=
=3D
3.11
from git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6

I don't try to debug it for the moment because it is on my main compute=
r
and have valuable data on my ssd.

=46or completeness, here is the full list of pci devices on my pc :

    [fredo:~] $ lspci
    00:00.0 Host bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI
to PCI bridge (external gfx0 port B) (rev 02)
    00:00.2 IOMMU: Advanced Micro Devices [AMD] nee ATI RD990 I/O Memor=
y
Management Unit (IOMMU)
    00:02.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI
to PCI bridge (PCI express gpp port B)
    00:04.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI
to PCI bridge (PCI express gpp port D)
    00:05.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI
to PCI bridge (PCI express gpp port E)
    00:07.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI
to PCI bridge (PCI express gpp port G)
    00:11.0 SATA controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] (rev 40)
    00:12.0 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
    00:12.2 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB EHCI Controller
    00:13.0 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
    00:13.2 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB EHCI Controller
    00:14.0 SMBus: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus
Controller (rev 42)
    00:14.2 Audio device: Advanced Micro Devices [AMD] nee ATI SBx00
Azalia (Intel HDA) (rev 40)
    00:14.3 ISA bridge: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 LPC host controller (rev 40)
    00:14.4 PCI bridge: Advanced Micro Devices [AMD] nee ATI SBx00 PCI
to PCI Bridge (rev 40)
    00:14.5 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB OHCI2 Controller
    00:16.0 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
    00:16.2 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB EHCI Controller
    00:18.0 Host bridge: Advanced Micro Devices [AMD] Family 15h
Processor Function 0
    00:18.1 Host bridge: Advanced Micro Devices [AMD] Family 15h
Processor Function 1
    00:18.2 Host bridge: Advanced Micro Devices [AMD] Family 15h
Processor Function 2
    00:18.3 Host bridge: Advanced Micro Devices [AMD] Family 15h
Processor Function 3
    00:18.4 Host bridge: Advanced Micro Devices [AMD] Family 15h
Processor Function 4
    00:18.5 Host bridge: Advanced Micro Devices [AMD] Family 15h
Processor Function 5
    01:00.0 VGA compatible controller: Advanced Micro Devices [AMD] nee
ATI Caicos [Radeon HD 6450]
    01:00.1 Audio device: Advanced Micro Devices [AMD] nee ATI Caicos
HDMI Audio [Radeon HD 6400 Series]
    02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168 PCI Express Gigabit Ethernet controller (rev 09)
    03:00.0 USB controller: ASMedia Technology Inc. ASM1042 SuperSpeed
USB Host Controller
    04:00.0 USB controller: ASMedia Technology Inc. ASM1042 SuperSpeed
USB Host Controller
    05:05.0 Ethernet controller: 3Com Corporation 3c940
10/100/1000Base-T [Marvell] (rev 10)
    [fredo:~] $
