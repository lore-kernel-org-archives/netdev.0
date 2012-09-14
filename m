From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: e1000e: Disabling IRQ #57 .. machine dies
Date: Fri, 14 Sep 2012 16:40:38 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B62630DCBBB2@ORSMSX102.amr.corp.intel.com>
References: <504F87F1.5040004@opensuse.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?iso-8859-1?Q?Cristian_Rodr=EDguez?= <crrodriguez@opensuse.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:62120 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752748Ab2INQkk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 12:40:40 -0400
In-Reply-To: <504F87F1.5040004@opensuse.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg]
> On Behalf Of Cristian Rodr=EDguez
> Sent: Tuesday, September 11, 2012 11:50 AM
> To: Netdev
> Subject: e1000e: Disabling IRQ #57 .. machine dies
>=20
> Hi:
>=20
> In current linus tree, in a machine using the e1000e driver
>=20
> hwinfo --netcard
> 22: PCI 400.0: 0200 Ethernet controller
>   [Created at pci.319]
>   Unique ID: rBUF.cuT2KaC3ZS1
>   Parent ID: HnsE.Z52SDLRIaH2
>   SysFS ID: /devices/pci0000:00/0000:00:1c.5/0000:04:00.0
>   SysFS BusID: 0000:04:00.0
>   Hardware Class: network
>   Model: "Intel 82574L Gigabit Network Connection"
>   Vendor: pci 0x8086 "Intel Corporation"
>   Device: pci 0x10d3 "82574L Gigabit Network Connection"
>   SubVendor: pci 0x1043 "ASUSTeK Computer Inc."
>   SubDevice: pci 0x8369
>   Driver: "e1000e"
>   Driver Modules: "e1000e"
>   Device File: eth0
>   Memory Range: 0xf7d00000-0xf7d1ffff (rw,non-prefetchable)
>   I/O Ports: 0xd000-0xdfff (rw)
>   Memory Range: 0xf7d20000-0xf7d23fff (rw,non-prefetchable)
>   IRQ: 17 (no events)
>   Link detected: yes
>   Module Alias: "pci:v00008086d000010D3sv00001043sd00008369bc02sc00i0=
0"
>   Driver Info #0:
>     Driver Status: e1000e is active
>     Driver Activation Cmd: "modprobe e1000e"
>   Config Status: cfg=3Dno, avail=3Dyes, need=3Dno, active=3Dunknown
>   Attached to: #15 (PCI bridge)
>=20
>=20
>=20
> cat /proc/interrupts
>=20
> 57 IR-PCI-MSI-edge      eth0
>=20
> the driver works after a while, but then a single message
>=20
> "Disabling IRQ #57"
>=20

Hello,

I'm sorry you're having problems with out parts.  Can you provide some =
more info on this issue?  What version of the driver are you using?  Is=
 the only problem that this driver dies or are there other symptoms?  W=
hat does the dmesg say for the e1000e driver at load?  It usually list =
whether its using MSI/MSI-X, and some other info.  Can you provide an l=
spci -vvv output for the 82574L device and the dmesg info?  Is the "Dis=
abling IRQ #57 message appearing in the dmesg log or somewhere else?  C=
an you try loading the driver with the module parameter IntMode=3D0 to =
try the device in legacy interrupt mode, if its not already in that mod=
e.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
