From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fib_hash: embed initial hash table in fn_zone
Date: Thu, 14 Oct 2010 21:22:39 +0200
Message-ID: <1287084159.2659.0.camel@edumazet-laptop>
References: <1287073458.2712.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64543 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754434Ab0JNT37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 15:29:59 -0400
Received: by wwj40 with SMTP id 40so17489wwj.1
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 12:29:58 -0700 (PDT)
In-Reply-To: <1287073458.2712.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 octobre 2010 =C3=A0 18:24 +0200, Eric Dumazet a =C3=A9crit =
:
> While looking for false sharing problems, I noticed=20
> sizeof(struct fn_zone) was small (28 bytes) and possibly sharing a ca=
che
> line with an often written kernel structure.
>=20
> Most of the time, fn_zone uses its initial hash table of 16 slots.
>=20
> We can avoid the false sharing problem by embedding this initial hash
> table in fn_zone itself, so that sizeof(fn_zone) > L1_CACHE_BYTES
>=20
> We did a similar optimization in commit a6501e080c (Reduce memory nee=
ds
> and speedup lookups)
>=20
> Add a fz_revorder field to speedup fn_hash() a bit.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Oops, a last minute change was wrong, I'll resend a V2.

Thanks


