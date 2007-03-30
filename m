From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: [BUG] ethX misnumbered and one missing in mii-tool
Date: Fri, 30 Mar 2007 18:43:11 +0200
Message-ID: <20070330164311.GA10235@atjola.homenet>
References: <1175203383.6219.8.camel@localhost> <4807377b0703292121o6eef3bf2l998878cfd677d821@mail.gmail.com> <1175240543.6219.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDEV list <netdev@vger.kernel.org>
To: Andrei Popa <andrei.popa@i-neo.ro>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753939AbXC3QnQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1175240543.6219.10.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2007.03.30 10:42:23 +0300, Andrei Popa wrote:
> On Thu, 2007-03-29 at 21:21 -0700, Jesse Brandeburg wrote:
> with kernel 2.6.20.4(and build in e1000 driver):
> zeus ~ # uname -a
> Linux zeus 2.6.20.4-zeus3 #3 SMP Wed Mar 28 13:44:50 EEST 2007 x86_64
> Intel(R) Xeon(TM) CPU 3.00GHz GenuineIntel GNU/Linux
>=20
> the devices are recognized ok as eth0,eth1.eth2,eth3,eth4 but misnume=
red
> and one missing int mii-tool/ethtool
>=20
> Intel(R) PRO/1000 Network Driver - version 7.3.15-k2-NAPI
> Copyright (c) 1999-2006 Intel Corporation.
> ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> PCI: Setting latency timer of device 0000:03:00.0 to 64
> e1000: 0000:03:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> 00:15:17:21:0c:08
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> ACPI: PCI Interrupt 0000:03:00.1[B] -> GSI 17 (level, low) -> IRQ 17
> PCI: Setting latency timer of device 0000:03:00.1 to 64
> e1000: 0000:03:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> 00:15:17:21:0c:09
> e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 18 (level, low) -> IRQ 18
> PCI: Setting latency timer of device 0000:05:00.0 to 64
> e1000: 0000:05:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> 00:15:17:17:b7:68
> e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> ACPI: PCI Interrupt 0000:05:00.1[B] -> GSI 19 (level, low) -> IRQ 19
> PCI: Setting latency timer of device 0000:05:00.1 to 64
> e1000: 0000:05:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> 00:15:17:17:b7:69
> e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> ACPI: PCI Interrupt 0000:06:02.0[A] -> GSI 27 (level, low) -> IRQ 27
> e1000: 0000:06:02.0: e1000_probe: (PCI-X:100MHz:64-bit)
> 00:0e:0c:ba:a8:50
> e1000: eth4: e1000_probe: Intel(R) PRO/1000 Network Connection
>=20
> zeus ~ # mii-tool
> eth2: no link
> eth5: negotiated 100baseTx-FD, link ok
> eth6: no link
> eth7: no link
> zeus ~ #
>=20
> ethtool shows the same

The "misnaming" might be due to udev renaming the devices. Here, on
debian, there are automatically created static rules for network device=
s
in /etc/udev/rules.d/z25_persistent-net.rules, which you might want to
adjust to meet your expectations.

HTH
Bj=F6rn
