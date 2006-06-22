From: Lukasz Stelmach <stlman@poczta.fm>
Subject: Re: ipv6 source address selection in addrconf.c (2.6.17)
Date: Thu, 22 Jun 2006 13:04:17 +0200
Message-ID: <449A7931.7090304@poczta.fm>
References: <44986AE6.6090102@poczta.fm>	<44994CB3.6070302@poczta.fm>	<4499CEF4.2050308@poczta.fm> <20060622.092659.76693840.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAB7DE8C61555FC562BF19CB8"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.poczta.interia.pl ([80.48.65.8]:64343 "EHLO
	smtp.poczta.interia.pl") by vger.kernel.org with ESMTP
	id S1030624AbWFVLEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 07:04:45 -0400
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20060622.092659.76693840.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAB7DE8C61555FC562BF19CB8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <4499CEF4.2050308@poczta.fm> (at Thu, 22 Jun 2006 00:57:56 +=
0200), Lukasz Stelmach <stlman@poczta.fm> says:
>=20
>> Lukasz Stelmach wrote:
>>> Lukasz Stelmach wrote:
[....]
>>
>> fd24:6f44:46bd:face:EUI64 fd24:6f44:46bd:face:RANDOM
>> and
>> 2002:531f:d667:face:EUI64 2002:531f:d667:face::RANDOM
>>
>> there seem to be no way to prefere 2002:: over fc00:: in rule 7 and it=
 will be
>> selected as long as it is before 2002:: on the list. I can see here th=
at an
>> implicit assumption has been made that an interface either is multihom=
ed or
>> "private". The seventh rule should not IMHO break the whole process of=

>> selection but rather mark as selectable all "private" (random) address=
es. And
>> it should rather be done before rule 6.
>=20
> Hmm? We do not have such intention.
> In above case, when you connect to 2001:200:0:8002:203:47ff:fea5:3085,
> either 2002:531f:d667:face:EUI64 or 2002:531f:d667:face::RANDOM
> should be selected (depending on if use_tempaddr >=3D 2),
> by the longest matching rule (Rule 8).

I've chewd the code line by line and it tastes like it should work the wa=
y you
say... OK I see the problem. I've used ifconfig which doesn't show
"deprecated" flag and "valid"/"prefered" times which, combined with "priv=
acy",
*seem* to cause some problems . I don't know yet if it is a problem of pr=
oper
intervals in radvd.conf or is there still a bug in kernel. I'll let you k=
now
when I learn it.

OK. That's enough for now. Let me get back to the real work ;-)


Best regards.
--=20
By=C5=82o mi bardzo mi=C5=82o.                    Czwarta pospolita kl=C4=
=99ska, [...]
>=C5=81ukasz<                      Ju=C5=BC nie katolicka lecz z=C5=82odz=
iejska.  (c)PP


--------------enigAB7DE8C61555FC562BF19CB8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFEmnk9NdzY8sm9K9wRAjiiAJ99Oe5uJ3x52L83qSOw7ZAljRsK8ACeN15P
0rU7bHcEci9koQyWApOpbyk=
=CvgD
-----END PGP SIGNATURE-----

--------------enigAB7DE8C61555FC562BF19CB8--
