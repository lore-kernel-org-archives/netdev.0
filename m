From: Andre Schwarz <andre.schwarz@matrix-vision.de>
Subject: Re: "eth1: Could not attach to PHY" on MPC8349e-MITX
Date: Thu, 04 Dec 2008 18:41:54 +0100
Message-ID: <49381662.2020302@matrix-vision.de>
References: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, afleming@freescale.com, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Timur,

is it possible that the PHY adress doesn't match the one specified in
the dts ?

regards,
Andre

Timur Tabi schrieb:
> The Freescale MPC8349e-MITX reference board has two TSECs, the second
> of which (eth1) is attached to a Vitesse 7385 5-port switch.
>
> Using the latest U-Boot, Kernel, and device tree, I cannot bring up
> eth1.  When I try, I get this message:
>
> [root@tintin root]# ifconfig eth1 up
> 0:01 not found
> eth1: Could not attach to PHY
> SIOCSIFFLAGS: No such device
>
> Unfortunately, I don't even know what this means.
>
> I believe my network configuration is correct.  Here's what ifconfig
> says about eth1:
>
> eth1      Link encap:Ethernet  HWaddr 00:E0:0C:00:8C:02
>           inet addr:192.168.2.141  Bcast:192.168.255.255  Mask:255.255.0.0
>           BROADCAST MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>           Base address:0x4000
>
> eth1 does work in U-boot, so I know it can be made to work (and I know
> the 7385's firmware is uploaded), I just don't know what needs to be
> done in Linux.
>   =



MATRIX VISION GmbH, Talstra=DFe 16, DE-71570 Oppenweiler  - Registergericht=
: Amtsgericht Stuttgart, HRB 271090
Gesch=E4ftsf=FChrer: Gerhard Thullner, Werner Armingeon, Uwe Furtner
