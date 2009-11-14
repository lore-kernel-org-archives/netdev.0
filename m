From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP throughput drops sharply around MTU of 180 bytes
Date: Sat, 14 Nov 2009 09:53:04 +0100
Message-ID: <4AFE6FF0.3030101@gmail.com>
References: <51d384e10911140028r76e1aefei3a224b5c542d82e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ang Way Chuang <wcang79@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56539 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686AbZKNIxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 03:53:02 -0500
In-Reply-To: <51d384e10911140028r76e1aefei3a224b5c542d82e8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ang Way Chuang a =E9crit :
> Hi kernel networking gurus,
>=20
>       I came across a situation where I need to evaluate the packing
> efficiency of
> small packets. Because TCP is byte oriented protocol, there is no way
> to force it
> to generate small packets, so I forced it by adjusting MTU.
>=20
>      However, through the experiment, I found that measured throughpu=
t
> of TCP stream dropped significantly if MTU is set to value less than =
180 bytes.
> At first, I thought it must be some bugs on my code. So, I decided to=
 repeat
> the test over a dedicated 10Mbps Ethernet link. The results that I me=
asured
> over Ethernet is shown below:
>=20
>=20
> MTU                 Throughput (Mbps)
> -----                  --------------
> 181                  4.50
> 180                  4.39
> 179                  3.05
> 178                  3.04
>=20
>      I used iperf throughout the tests. Can someone enlighten me on t=
his matter?
> Why the throughput drops sharply if MTU is less than 180 bytes? Is th=
ere some
> special meaning associated with 180 that I don't know of?
>=20
>    Some basic information about my system:
> kernel version: 2.6.27.5-117.fc10.x86_64
> distro: fedora 10
> CPU: Pentium 4 3.00 GHz
>=20
>     Should you need more information, I shall gladly cooperate. Pleas=
e keep me
> in the loop because it is hard for me to cop with the volume of email=
s on netdev
> mailing list.
>=20

Oh well, this reminds me TCP_MAXSEG doesnt work as expected...
