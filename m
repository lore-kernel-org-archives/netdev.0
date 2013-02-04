From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 5 Feb 2013 10:21:22 +1100
Message-ID: <20130205102122.07abc37d0ee81304f9014cde@canb.auug.org.au>
References: <20130202142253.e31167bf695f000c0c78f4cc@canb.auug.org.au>
	<20130202100506.GB1864@minipsycho.orion>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__5_Feb_2013_10_21_22_+1100_aYJP.4SMmk8pTUSY"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	=?UTF-8?B?IllPU0hJRlVKSSBIaWRlYWtpIC8g5ZCJ?=
	 =?UTF-8?B?6Jek6Iux5piOIg==?= <yoshfuji@linux-ipv6.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130202100506.GB1864@minipsycho.orion>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__5_Feb_2013_10_21_22_+1100_aYJP.4SMmk8pTUSY
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

On Sat, 2 Feb 2013 11:05:06 +0100 Jiri Pirko <jiri@resnulli.us> wrote:
>
> >diff --cc net/ipv6/route.c
> >index 363d8b7,f3328bc..0000000
> >--- a/net/ipv6/route.c
> >+++ b/net/ipv6/route.c
> >@@@ -928,7 -884,7 +884,7 @@@ restart
> >  	dst_hold(&rt->dst);
> >  	read_unlock_bh(&table->tb6_lock);
> > =20
> >- 	if (!rt->n && !(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL)))
> > -	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
> >++	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL | RTF_GATEWAY)))
>=20
> I believe that no change here is correct to do. RTF_LOCAL here is needed
> only before Yoshifuji's "IPv6 rt->n removal"

Thanks for the feedback.  I have removed the " | RTF_LOCAL" from the
merge resolution.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__5_Feb_2013_10_21_22_+1100_aYJP.4SMmk8pTUSY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJREEJyAAoJEECxmPOUX5FEWqEQAI032QMnyppQcoIV3A4ecA85
LWXvn1CmTMYXZDOHX5ZkWISR8chRbjyTRSK/xMX4i7n8XRmMqlKYN6c9El50WHr2
Kg5tKBODYE1JQpXS36KOSSa3NOyZODyRwabauh6t9Mzj+MwvL+u4sjjJYq4KSgoX
/VceKS1g5xlM5b7mwZioZDDGOiLW2pkxRZRu9YYavXptAK752p4V8fmYyixNQ2s1
QzpWDCDO2xdbT0miu3LwgC7QSi46gNXlFi4MC6mE5PdlKX4eNR/lL2lV7w4PPPEf
uYA1iFcm51iZOvXTAZu/NLn0MoYlSZ6Am9Ek8bM9MIcjhdQzwgxnznC+l/+pi4+R
civP40enhipsQZ1qJccpsPob+npe+FvxFQXnCGg0jZGRZAtQqG84FnhEtliuP5qY
vTT64cDl7pA+WqV64h7bN1V52sPGMZDc2s4AVEG4CEbg6YNwjqeVgHhmoUDMmTE/
l3dTbjU0hbLzy/esh8Kg5U30m/ZQGnWp9s7NmtW3SNCkQdyvMG3nUXHCETpoCrrn
IE0uHwnZ756DUeVGFtOjyEISp7B9KrsR9WlG6tBnqkcxO+HRPmSnvakSFidzF2LZ
wefKQ2OtSCqtkZPvlicPWCwAFtarhksblk44S1byqVOuNTU5Ej7DuIkPgp/6qkkQ
rPQlHvl9AK3aOwrD5UbH
=da3w
-----END PGP SIGNATURE-----

--Signature=_Tue__5_Feb_2013_10_21_22_+1100_aYJP.4SMmk8pTUSY--
