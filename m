From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] bonding: Doesn't support IPv6
Date: Sat, 29 Oct 2011 10:49:22 +0200
Message-ID: <1319878162.2586.5.camel@edumazet-laptop>
References: <4EAB5455.5080004@8192.net>
	 <CAHXqBF+CcX=FQNSSsdsEAc9jAqi0G3RNLPjRCcc7wJ+QYnzzSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John <linux@8192.net>, netdev@vger.kernel.org, andy@greyhouse.net
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:35746 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab1J2Itb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 04:49:31 -0400
Received: by ywm3 with SMTP id 3so4355795ywm.19
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2011 01:49:31 -0700 (PDT)
In-Reply-To: <CAHXqBF+CcX=FQNSSsdsEAc9jAqi0G3RNLPjRCcc7wJ+QYnzzSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 29 octobre 2011 =C3=A0 09:55 +0200, Micha=C5=82 Miros=C5=82aw=
 a =C3=A9crit :
> 2011/10/29 John <linux@8192.net>:
> > --- a/drivers/net/bonding/bond_main.c   2011-04-19 11:18:48.0000000=
00 -0700
> > +++ b/drivers/net/bonding/bond_main.c   2011-10-27 11:26:20.0000000=
00 -0700
> [...]
> > +               v6hash =3D (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
>=20
> This XORs in only 3 of 4 bytes, and assuming count > 256 (its unlikel=
y
> you have more than 256 slaves in bond) the most significant byte is
> wasted. It should be:
>=20
> v6hash ^=3D v6hash >> 16;
> v6hash ^=3D v6hash >> 8;
>=20
> Same for IPv4 part.
>=20
> OTOH, if that was your intention, then the description in your mail w=
as wrong.
>=20

Same end result :)
