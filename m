From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: tg3: tg3_stop_block timed out
Date: Tue, 8 Aug 2006 01:24:38 +0200
Message-ID: <200608080124.38823.bernd-schubert@gmx.de>
References: <eb8fmt$6lf$1@sea.gmane.org> <1154992063.5328.3.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:156 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751198AbWHGXYd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:24:33 -0400
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1154992063.5328.3.camel@rh4>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

thanks for your help!

On Tuesday 08 August 2006 01:07, Michael Chan wrote:
> > ... [many hamilton not responding messages]
> > 4554928.798000] nfs: server hamilton not responding, still trying
> > [4554935.319000] nfs: server hamilton not responding, still trying
> > [4555468.940000] NETDEV WATCHDOG: eth1: transmit timed out
> > [4555468.940000] tg3: eth1: transmit timed out, resetting
> > [4555469.044000] tg3: tg3_stop_block timed out, ofs=3D3400 enable_b=
it=3D2
> > [4555469.147000] tg3: tg3_stop_block timed out, ofs=3D2400 enable_b=
it=3D2
> > [4555469.251000] tg3: tg3_stop_block timed out, ofs=3D1400 enable_b=
it=3D2
> > [4555469.354000] tg3: tg3_stop_block timed out, ofs=3Dc00 enable_bi=
t=3D2
> > [4555469.433000] tg3: eth1: Link is down.
> > [4555472.593000] tg3: eth1: Link is up at 1000 Mbps, full duplex.
> > [4555472.594000] tg3: eth1: Flow control is on for TX and on for RX=
=2E
> > [4555498.016000] nfs: server 129.206.21.200 OK
> > [4555648.015000] nfs: server 129.206.21.200 OK
> > ... [many ok messages]
>
> I need to know what hardware you're using so please send me the tg3
> probing output for eth1 when you load the driver. Do you have TSO
> enabled?


tg3.c:v3.49 (Feb 2, 2006)
acpi_bus-0201 [01] bus_set_power         : Device is not power manageab=
le
eth1: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:100MHz:64-bi=
t) 10/100/1000BaseT Ethernet 00:e0:81:2b:aa:28
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TS=
Ocap[0]
eth1: dma_rwctrl[769f4000] dma_mask[64-bit]
eth2: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:100MHz:64-bi=
t) 10/100/1000BaseT Ethernet 00:e0:81:2b:aa:29
eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TS=
Ocap[1]
eth2: dma_rwctrl[769f4000] dma_mask[64-bit]

The NIC is onboard a Tyan S2882.=20

0000:02:09.0 Ethernet controller: Broadcom Corporation NetXtreme BCM570=
4 Gigabit Ethernet (rev 03)
        Subsystem: Broadcom Corporation: Unknown device 1644
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 24
        Memory at fc8c0000 (64-bit, non-prefetchable) [size=3D64K]
        Memory at fc8b0000 (64-bit, non-prefetchable) [size=3D64K]
        Capabilities: [40]      Capabilities: [48] Power Management ver=
sion 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D=
0/3 Enable-

0000:02:09.1 Ethernet controller: Broadcom Corporation NetXtreme BCM570=
4 Gigabit Ethernet (rev 03)
        Subsystem: Broadcom Corporation: Unknown device 1644
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 25
        Memory at fc8e0000 (64-bit, non-prefetchable) [size=3D64K]
        Memory at fc8d0000 (64-bit, non-prefetchable) [size=3D64K]
        Capabilities: [40]      Capabilities: [48] Power Management ver=
sion 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D=
0/3 Enable-


The driver is compiled into the kernel (its a nfs-root booted system an=
d=20
NIC modules are presently not supported by our initrd).
So the default option for tso is set. Is there any way to determine the=
=20
present tso setting? With ethtool I only find the options to turn it of=
f/on,=20
but none to query the current state.


Thanks a lot,
Bernd


--=20
Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg

