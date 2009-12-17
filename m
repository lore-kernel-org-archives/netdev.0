From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 2/2] udp: udp_lib_get_port start at a different bucket on
 different processors
Date: Thu, 17 Dec 2009 15:09:11 +0100
Message-ID: <4B2A3B87.8020603@gmail.com>
References: <4B2933FC.7070306@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48431 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757344AbZLQOJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 09:09:55 -0500
In-Reply-To: <4B2933FC.7070306@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/12/2009 20:24, Lucian Adrian Grijincu a =C3=A9crit :
>=20
> On SMP, when ports are not allocated randomly, using the same startin=
g
> port on all processors will lead to bad performance as all processors
> will try to get the same hashbucket spinlock: only one will succeed,
> the rest will spin madly.
>=20
> We solve this problem by making each processor start searching from a
> different port. To not skip possibly valid port ranges we renormalize
> the hint value too.
>=20
> Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
> ---
>  net/ipv4/udp.c |   12 +++++++++---
>  1 files changed, 9 insertions(+), 3 deletions(-)
>=20
>=20

This makes no sense. You correct a bad performance issue bringed by you=
r previous patch ?

Please submit one patch, with no performance regression.

I suggest you use a per_cpu hint if you really want to be fast...

Thanks
