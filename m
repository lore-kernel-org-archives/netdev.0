From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Tue, 22 Apr 2014 19:03:19 +0100
Message-ID: <1398189799.7767.80.camel@deadeye.wl.decadent.org.uk>
References: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XKkUgCEfnqrbLRXZ+mtn"
Cc: netdev@vger.kernel.org, Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>
To: David Gibson <dgibson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53912 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932335AbaDVSD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 14:03:28 -0400
In-Reply-To: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XKkUgCEfnqrbLRXZ+mtn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-04-22 at 14:14 +1000, David Gibson wrote:
> I believe I've found a problem with netlink handling which can be
> triggered on Cisco enic devices with a large number (30-40) of virtual
> functions.  I believe this is the cause of a real customer problem
> we've seen.
>=20
>  * When requesting a list of interfaces with RTM_GETLINK, enic devices
>    (and currently, _only_ enic devices) report IFLA_VF_PORTS
>    information=20
>=20
>  * IFLA_VF_PORTS information has at least 90 bytes ber virtual function
>=20
>  * Unlike IFLA_VFINFO_LIST, the ports information is always reported,
>    regardless of the setting of the IFLA_EXT_MASK parameter
[...]

So I think you should make reporting of IFLA_VF_PORTS dependent on the
same flag as IFLA_VFINFO_LIST.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-XKkUgCEfnqrbLRXZ+mtn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1au5+e/yOyVhhEJAQo+Xw/9FrRh7BnKaOUyEeacnvHgArlvopulSWBu
ZlW73IUMSYnxyRPwZlL/CK86w/1Ybo/lMedN1P2NVXis+w+LuVYqixCvn5RUzlOc
Vm3jj1AT90ZJNNc2RdXbUgimF5Pt5j4B25w65N6LOFHrres5dZpIw6oLDuUPxEBu
Bs0derpfD5QmFBuch256I1kl9GKpqzj1w5q17VTRTpOhGxrOlEv9EmYjwWd3IQWq
1KPmQhErRpTAlQD0EYSNqmgPXezLZOhCEc+Bq7dy0jJ7xUAfgJwcMEv+M39obVDX
txJ19u7OKCNVUv9dBL/V8ZM3QVPnYlszc7giDW+an8HaQ/t0fzTR7ZoBM9xoz/UM
UgZZOEp7os295iU5wYIxFHQfaiJ+FOvg50jrW1iLWIy6b+DRYhW0YSNLCvbATl/u
IpKRaRAdA2PlujxyrblkR+uv/IbUUgmPKPXHcTZzSS2PFWcggapvoHIjJgZKWTen
tR4Qf7O0B2e7bkSj3xzAQ+qa9Z0nEQLRGl8hSZwWKfr6VEfGMHkj2NURoMlwi1Ia
7UZBO9H6q8PBAlMKK9NU9UjqfTbfYJmk+mup5SneG03TYTacDvvPUE8/WOZDB41r
cm+hBDyDLvvqp68q6YFjSTKYMt8/fIU+BlMumgyLw34MPDUh8J067pegFk26NHYj
whQ2F1uDUDg=
=lThU
-----END PGP SIGNATURE-----

--=-XKkUgCEfnqrbLRXZ+mtn--
