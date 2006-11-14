From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 4/5] Add tsi108/9 On Chip Ethernet device driver support
Date: Tue, 14 Nov 2006 10:41:04 -0500
Message-ID: <4559E390.4050205@garzik.org>
References: <200611090349.kA93nDBl003600@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tie-fei.zang@freescale.com,
	Alexandre.Bounine@tundra.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42176 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S966001AbWKNPlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:41:09 -0500
To: akpm@osdl.org
In-Reply-To: <200611090349.kA93nDBl003600@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Zang Roy-r61911 <tie-fei.zang@freescale.com>
>=20
> Add tsi108/9 on chip Ethernet controller driver support.
>=20
> The driver code collects the feedback of previous posting form the ma=
iling
> list and gives the update.
>=20
> MPC7448HPC2 platform in arch/powerpc uses tsi108 bridge.
>=20
> The following is a brief description of the Ethernet controller:
>=20
> The Tsi108/9 Ethernet Controller connects Switch Fabric to two indepe=
ndent
> Gigabit Ethernet ports,E0 and E1.  It uses a single Management interf=
ace to
> manage the two physical connection devices (PHYs).  Each Ethernet por=
t has
> its own statistics monitor that tracks and reports key interface
> statistics.  Each port supports a 256-entry hash table for address
> filtering.  In addition, each port is bridged to the Switch Fabric th=
rough
> a 2-Kbyte transmit FIFO and a 4-Kbyte Receive FIFO.
>=20
> Each Ethernet port also has a pair of internal Ethernet DMA channels =
to
> support the transmit and receive data flows.  The Ethernet DMA channe=
ls use
> descriptors set up in memory, the memory map of the device, and acces=
s via
> the Switch Fabric.  The Ethernet Controller=E2=80=99s DMA arbiter han=
dles
> arbitration for the Switch Fabric.  The Controller also has a registe=
r bus
> interface for register accesses and status monitor control.
>=20
> The PMD (Physical Media Device) interface operates in MII, GMII, or T=
BI
> modes.  The MII mode is used for connecting with 10 or 100 Mbit/s PMD=
s.=20
> The GMII and TBI modes are used to connect with Gigabit PMDs.  Intern=
al
> data flows to and from the Ethernet Controller through the Switch Fab=
ric.=20
> Each
>=20
> Ethernet port uses its transmit and receive DMA channels to manage da=
ta
> flows through buffer descriptors that are predefined by the system (t=
he
> descriptors can exist anywhere in the system memory map).  These
> descriptors are data structures that point to buffers filled with dat=
a
> ready to transmit over Ethernet, or they point to empty buffers ready=
 to
> receive data from Ethernet.
>=20
> Signed-off-by: Alexandre Bounine <Alexandre.Bounine@tundra.com>
> Signed-off-by: Roy Zang	<tie-fei.zang@freescale.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied

