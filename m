From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add const qualifiers where possible
Date: Fri, 21 Oct 2011 10:21:03 +0200
Message-ID: <1319185263.2338.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1319179993.2854.63.camel@edumazet-laptop>
	 <20111021.025549.113655582134326444.davem@redhat.com>
	 <20111021.033648.1029307040209750463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42906 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab1JUIVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 04:21:08 -0400
Received: by wyg36 with SMTP id 36so3694804wyg.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 01:21:07 -0700 (PDT)
In-Reply-To: <20111021.033648.1029307040209750463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 octobre 2011 =C3=A0 03:36 -0400, David Miller a =C3=A9cr=
it :

> You can't make the argument to __sk_dst_get() const, because lock_is_=
held()
> does not take a const pointer argument.
>=20
> include/net/sock.h: In function =E2=80=98__sk_dst_get=E2=80=99:
> include/net/sock.h:1315:2: warning: passing argument 1 of =E2=80=98lo=
ck_is_held=E2=80=99 discards =E2=80=98const=E2=80=99 qualifier from poi=
nter target type [enabled by default]
> include/linux/lockdep.h:324:12: note: expected =E2=80=98struct lockde=
p_map *=E2=80=99 but argument is of type =E2=80=98const struct lockdep_=
map *=E2=80=99
>=20
> I'm reverting.

Thats strange, I built with LOCKDEP enabled here...

# grep LOCKDEP .config
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_LOCKDEP=3Dy
# CONFIG_DEBUG_LOCKDEP is not set


I'll take a look,
Thanks
