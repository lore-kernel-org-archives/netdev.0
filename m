From: Lukasz Stelmach <stlman@poczta.fm>
Subject: ipv6 source address selection in addrconf.c (2.6.17)
Date: Tue, 20 Jun 2006 23:38:46 +0200
Message-ID: <44986AE6.6090102@poczta.fm>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig762CEE2DCD88B749B43EF918"
Cc: =?UTF-8?B?xYF1a2FzeiBTdGVsbWFjaA==?= <stlman@poczta.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.poczta.interia.pl ([80.48.65.8]:55373 "EHLO
	smtp.poczta.interia.pl") by vger.kernel.org with ESMTP
	id S1750739AbWFTVi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 17:38:58 -0400
Received: from poczta.interia.pl (mi01.poczta.interia.pl [10.217.12.1])
	by smtp.poczta.interia.pl (INTERIA.PL) with ESMTP id DE55FD0F16
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 23:38:50 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig762CEE2DCD88B749B43EF918
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Greetings.

net/ipv6/addrconf.c:971 is
/* Rule 2: Prefer appropriate scope */
if (hiscore.rule < 2) {
        hiscore.scope =3D __ipv6_addr_src_scope(hiscore.addr_type);
        hiscore.rule++;
}

I am afraid, that it does not make any sense for I find no place where a =
value
is assigned to hiscore.addr_type. There are some more references to
hiscore.addr_type below but the only assignment is when the whole structu=
re is
cleaned with memset(3)

I found it when I was trying to figure out why when trying to connect to

2001:200:0:8002:203:47ff:fea5:3085 (www.kame.net)

with two global addresses assigned to the ethernet card

fd24:6f44:46bd:face::254
2002:531f:d667:face::254

rule 8 does not work and the first address is chosen.


Please CC answers.
--=20
By=C5=82o mi bardzo mi=C5=82o.                    Czwarta pospolita kl=C4=
=99ska, [...]
>=C5=81ukasz<                      Ju=C5=BC nie katolicka lecz z=C5=82odz=
iejska.  (c)PP




--------------enig762CEE2DCD88B749B43EF918
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFEmGrsNdzY8sm9K9wRAl1jAJ0WK/0lCe/dSjIlhaDZI19I+qOSnwCfbwpf
CqMDxWQPw9Ka4OxssZ5+stc=
=uIbg
-----END PGP SIGNATURE-----

--------------enig762CEE2DCD88B749B43EF918--
