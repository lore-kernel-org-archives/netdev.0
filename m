From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 1/4] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Thu, 01 Mar 2012 12:41:42 +0100
Message-ID: <4F4F6076.5050903@nod.at>
References: <1328400892-22409-1-git-send-email-richard@nod.at> <1328400892-22409-3-git-send-email-richard@nod.at> <20120301112732.GA6806@1984>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig895AD0FC53FA46E1B9B5B8ED"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120301112732.GA6806@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig895AD0FC53FA46E1B9B5B8ED
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 01.03.2012 12:27, schrieb Pablo Neira Ayuso:
> On Sun, Feb 05, 2012 at 01:14:48AM +0100, Richard Weinberger wrote:
>> ipt_LOG and ip6_LOG have a lot of common code, merge them
>> to reduce duplicate code.
>>
>> Signed-off-by: Richard Weinberger <richard@nod.at>
>=20
> While testing this in my master branch I noticed one problem:
>=20
> IN=3Dwlan0 OUT=3D MAC=3Dxx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
> SRC=3D213.150.61.61 DST=3D192.168.1.133 LEN=3D40 TOS=3D0x00 PREC=3D0x00=
 TTL=3D117
> ID=3D10539 DF PROTO=3DTCP SPT=3D80 DPT=3D49013 WINDOW=3D0 RES=3D0x00 AC=
K RST
> URGP=3D0 PROTO=3DUDPLITE SPT=3D80 DPT=3D49013 LEN=3D45843 PROTO=3DICMP =
TYPE=3D0
> CODE=3D80 ID=3D45843 SEQ=3D48576
>=20
> While merging ipt_LOG and ip6t_LOG, you introduced some bug that
> corrupts the log line. Note the extra PROTO=3D, I don't have any UDPLIT=
E
> traffic here.
>=20
> Looks like a missing break in one switch.
>=20
> Would you send me a patch to fix this?
>=20

Sure. Do I have 48h to fix this?
I'm currently very busy.

Thanks,
//richard


--------------enig895AD0FC53FA46E1B9B5B8ED
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPT2B6AAoJEN9758yqZn9esF0H/iBZcy3Bs0JroQxUxSl5JNjU
L/jj9/1Y1+8Madw8nVRoCkNXflwZrqUnLW8hIZeanon8U1a6rx+UK+5UkkfaNXxL
9A3HifXg+GeG5VYb0LgIPmyyR8ZD/rZHNhwP8Xp1kVfQywhoBqOSFPnLQHhlvoQq
8m3wNU+C+BIor9Ksa8DXXqlv/GVg1rTIULfyBTp6lECxEtsUzIUIZ8Ljg1hq5d9p
ziDZ1xulBCtuRD+ODlxzEV5aeestO9ke7dwz+49pI2VA3wDwbJclYeSFFxesU9/r
YO/6mSULkbRNGB4BvOirI6hxTrBwnUgOaYk3OEYgca8tNcUo4xbcXYAbcEVeoXM=
=Penx
-----END PGP SIGNATURE-----

--------------enig895AD0FC53FA46E1B9B5B8ED--
