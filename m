From: Christian Hesse <list@eworm.de>
Subject: Re: [PATCH 1/1] ip-link: allow human readable output with base of
 1024 only for byte counts
Date: Mon, 30 Mar 2015 09:03:15 +0200
Message-ID: <20150330090315.68ce923d@leda.localdomain>
References: <1427369048-1433-1-git-send-email-list@eworm.de>
	<20150329225835.2cf0f770@uryu.home.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/QPcWPHtL3NO3mbJRH..hwjc"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, Christian Hesse <mail@eworm.de>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:37627 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbbC3HLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 03:11:43 -0400
In-Reply-To: <20150329225835.2cf0f770@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/QPcWPHtL3NO3mbJRH..hwjc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger <stephen@networkplumber.org> on Sun, 2015/03/29 22:58:
> On Thu, 26 Mar 2015 12:24:08 +0100
> Christian Hesse <list@eworm.de> wrote:
>=20
> > From: Christian Hesse <mail@eworm.de>
> >=20
> > Counting bytes with a base of 1024 is ok. Counting packets, errors, etc
> > that way makes no sense.
> > So only print byte counts with a base of 1024 if option -iec is given.
> >=20
> > Signed-off-by: Christian Hesse <mail@eworm.de>
>=20
> This changes the output which users expect, especially the packet counts
> should follow existing practice. And I doubt anyone would have 1024 error=
s.

With current code you can give -iec and everything (including errors) is
printed with IEC units. This patch changes it to only print byte counts with
IEC units, so error will be displayed with a base of 1000 always.

I think my patch changes things to what user expects, no?
--=20
main(a){char*c=3D/*    Schoene Gruesse                         */"B?IJj;MEH"
"CX:;",b;for(a/*    Chris           get my mail address:    */=3D0;b=3Dc[a+=
+];)
putchar(b-1/(/*               gcc -o sig sig.c && ./sig    */b/42*2-3)*42);}

--Sig_/QPcWPHtL3NO3mbJRH..hwjc
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVGPUzAAoJEIlFIdfMgPR2GwYH/37ct64DEscGetRUvOJGN2KR
yfv+0UTM3NeY10Ju/YXI7r6gNgm57BEU9J/u9zUkq8twh5lI5Ik/OmYr4LXGMuB1
l5N/pBQNdbg6ZeQsH9cUFJfkaENIGi4fkKB8tILLq+AzY9lNBz8HwgN4Cz3ggfJT
JJWGQmFBqkOB47J+zFW32w1eZjAH4BZBZ1gmnyNUbDZOobEQvx4Ud8f8pBj1TrNT
FNLO5J57wFVJV7QWAgzv/qQGBjHfc5gDHzfVv7dZU8O0Rnflm3Je82VgkmWM18iz
mpp1ZNU07p09cwGPl7+EMQ+IAa8Bftb+7DNx9MCDOTPRcRn5pOHcvhLvnWFDUH4=
=E02+
-----END PGP SIGNATURE-----

--Sig_/QPcWPHtL3NO3mbJRH..hwjc--
