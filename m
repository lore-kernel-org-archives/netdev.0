From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 1/4] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Fri, 02 Mar 2012 17:52:50 +0100
Message-ID: <4F50FAE2.4080903@nod.at>
References: <1328400892-22409-1-git-send-email-richard@nod.at> <1328400892-22409-3-git-send-email-richard@nod.at> <20120301112732.GA6806@1984> <4F4FEC83.6090504@nod.at> <20120302164945.GA13723@1984>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCBCEF1B047BB2CE5FDF55683"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120302164945.GA13723@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCBCEF1B047BB2CE5FDF55683
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 02.03.2012 17:49, schrieb Pablo Neira Ayuso:
> On Thu, Mar 01, 2012 at 10:39:15PM +0100, Richard Weinberger wrote:
>> Am 01.03.2012 12:27, schrieb Pablo Neira Ayuso:
>>> While merging ipt_LOG and ip6t_LOG, you introduced some bug that
>>> corrupts the log line. Note the extra PROTO=3D, I don't have any UDPL=
ITE
>>> traffic here.
>>>
>>> Looks like a missing break in one switch.
>>
>> I got confused by my own logic. :-\
>> Does the attached patch fix the issue?
>> It's based on "Netfilter: xt_LOG: Add timestamp support"
>=20
> This patch lacks of description. If you don't make it myself, I have
> to do it for you :-(
>=20
> Please, send me patches following the standard format next time.

It was a "does this patch solve the problem"-Patch.
Does it fix the problem?

If so, I'll send an official one...

Thanks,
//richard


--------------enigCBCEF1B047BB2CE5FDF55683
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPUPriAAoJEN9758yqZn9e80UIANX8yMFMPz4VkGtKNb+hsuyP
y6QCUqSz5et3h4uPgQBQLgYNQG3VZSJyMFaINnFtirVJw8Zj05V5MnODvsQNjMrB
TSgL0MnGPsygf+sP4asp5DQ4jxxKiW04l+24dWVIY20C9eLGlNYI0Ex3Dxw3bd2O
rsXoHdgpeYCztue6sBRzKhqrniJzqqYJnydnMkBjjb5pgBGUztjnm24ZQgz5/ypd
hlnehNhSDc9SvSDXd6SdL+BE0h1GLL82cH/dgWJyNr7ybWSDBuNWYI6+jHJlTZhS
4/rCo1y6YtrOCEBrjF3yM0V6OIa6NdmXnhH88cY7PRs2yEsklujPKvOHRrRvaD0=
=Rpk4
-----END PGP SIGNATURE-----

--------------enigCBCEF1B047BB2CE5FDF55683--
