From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [BUG] ixgbe: something wrong with queue selection ?
Date: Tue, 17 Apr 2012 02:16:27 -0700
Message-ID: <1334654187.2696.2.camel@jtkirshe-mobl>
References: <1334653608.6226.11.camel@edumazet-laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pdQQJrPrTlPo0yakR0at"
Cc: Greg Rose <gregory.v.rose@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34340 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484Ab2DQJQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 05:16:28 -0400
In-Reply-To: <1334653608.6226.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pdQQJrPrTlPo0yakR0at
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-04-17 at 11:06 +0200, Eric Dumazet wrote:
> Hi guys
>=20
> I have bad feelings with ixgbe and its multiqueue selection.
>=20
> On a quad core machine (Q6600), I get lots of reorderings on a single
> TCP stream.
>=20
>=20
> Apparently packets happily spread on all available queues, instead of a
> single one.
>=20
> This defeats GRO at receiver and TCP performance is really bad.
>=20
> # ethtool -S eth5|egrep "x_queue_[0123]_packets" ; taskset 1 netperf -H
> 192.168.99.1 ; ethtool -S eth5|egrep "x_queue_[0123]_packets"
>      tx_queue_0_packets: 24
>      tx_queue_1_packets: 26
>      tx_queue_2_packets: 32
>      tx_queue_3_packets: 16
>      rx_queue_0_packets: 11
>      rx_queue_1_packets: 47
>      rx_queue_2_packets: 27
>      rx_queue_3_packets: 22
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.99.1 (192.168.99.1) port 0 AF_INET
> Recv   Send    Send                         =20
> Socket Socket  Message  Elapsed             =20
> Size   Size    Size     Time     Throughput =20
> bytes  bytes   bytes    secs.    10^6bits/sec =20
>=20
>  87380  16384  16384    10.00    3866.43  =20
>      tx_queue_0_packets: 1653201
>      tx_queue_1_packets: 608000
>      tx_queue_2_packets: 541382
>      tx_queue_3_packets: 536543
>      rx_queue_0_packets: 434703
>      rx_queue_1_packets: 137444
>      rx_queue_2_packets: 131023
>      rx_queue_3_packets: 128407
>=20
> # ip ro get 192.168.99.1
> 192.168.99.1 dev eth5  src 192.168.99.2=20
>     cache  ipid 0x438b rtt 4ms rttvar 4ms cwnd 57 reordering 127
>=20
> # lspci -v -s 02:00.0
> 02:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit
> SFI/SFP+ Network Connection (rev 01)
> 	Subsystem: Intel Corporation Ethernet Server Adapter X520-2
> 	Flags: bus master, fast devsel, latency 0, IRQ 16
> 	Memory at f1100000 (64-bit, prefetchable) [size=3D512K]
> 	I/O ports at b000 [size=3D32]
> 	Memory at f1200000 (64-bit, prefetchable) [size=3D16K]
> 	Capabilities: [40] Power Management version 3
> 	Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable+ 64bit+
> 	Capabilities: [70] MSI-X: Enable+ Count=3D64 Masked-
> 	Capabilities: [a0] Express Endpoint, MSI 00
> 	Capabilities: [100] Advanced Error Reporting
> 	Capabilities: [140] Device Serial Number 00-1b-21-ff-ff-4a-fe-54
> 	Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
> 	Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
> 	Kernel driver in use: ixgbe
> 	Kernel modules: ixgbe
>=20
>=20

Adding Don Skidmore and Alex Duyck...

--=-pdQQJrPrTlPo0yakR0at
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPjTTrAAoJEOVv75VaS+3OSP0P+QFgq19ZVPi/HEdlpiBUpqJU
Fphm2zCUVl1uwd7xaIHHv6P92q4bPtCkaoA6npxLszTZlJEMnZsDdv54NhEW4s7J
d4mT1F48ZwFq1PLR7ofFpBuWffRzYZcfjnvpbNL8J/H4fL7ltypMS9QYcLw6Qskz
Z0DAG/ovYHPxc8+Dk9sBVVKlDA+YYj+zAQxUXJXXOO7yVHWwehelv9c9tyiC06K+
5cgLxPWnYs/CT8th6P7rLgVaPmcJLM5nSMNR53pk90wISb3mZfabafODL1AKNfOm
cGKOlFS6UCVilwEns1fnaRto0fILMMh4y0DIHnUNENwlvRB9BmYkCrjYX3Lzie7f
R0Un5k6sts8q+ZUTAmMDuRzFFY0CTkr4EryQP0TqE4/ZUFLNCMIMFOQ3hxCkld6p
x+7/2yhx6khsuk7RvJyxZ76PE73TGeUPqa6uC69fCGChJ/BELKPRnnrLVgfJmbvJ
jYzwjZuMCjaP4k1cwBTuP0wtruIh7o3HyqxTjYJr7cCx5cmixbLIcyUTtu9ERFDH
xwlRcZpGhvCixFBImyfI7TbC3eTDLr50cKfkyJ1MXUB20gpzmlaLq+GHvo9T2WCx
gXj6k5KgLV90l+AzlP6+sov0VsEzqIpSznH8tdBI+R/yhF1WwF9dGhJ6YATgNoXO
vkhAGe1y3cjlQwNptVH0
=gI2w
-----END PGP SIGNATURE-----

--=-pdQQJrPrTlPo0yakR0at--
