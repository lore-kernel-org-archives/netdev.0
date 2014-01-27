From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] 8139cp: remove a won't occurred BUG_ON
Date: Mon, 27 Jan 2014 11:54:46 +0000
Message-ID: <1390823686.2735.138.camel@deadeye.wl.decadent.org.uk>
References: <52E4C862.9050103@huawei.com>
	 <1390778623.2735.69.camel@deadeye.wl.decadent.org.uk>
	 <52E5B309.1080402@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wkZD5S0fdj1TjxzmNzgX"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55470 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753799AbaA0LzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 06:55:00 -0500
In-Reply-To: <52E5B309.1080402@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wkZD5S0fdj1TjxzmNzgX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-27 at 09:14 +0800, Wang Weidong wrote:
> On 2014/1/27 7:23, Ben Hutchings wrote:
> > On Sun, 2014-01-26 at 16:33 +0800, Wang Weidong wrote:
> >> when variable i go to the BUG_ON the value is equal to the CP_NUM_STAT=
S,
> >> so the BUG_ON won't occur, so remove it
> >=20
> > We hope that every BUG_ON() does not occur, but that doesn't mean they
> > should be removed.  This check is meant to catch mistakes when adding
> > new statistics.
> >=20
> > Ben.
> >=20
> Hi, Ben.
>=20
> Yeah, but I think If someone would add new statistics, he should take int=
o account
> it instead the BUG_ON helper.
>=20
> And that, I found some other drivers' get_ethtool_stats no have BUG_ON. S=
hould we
> add the BUG_ON into them?
[...]

The important thing is that the get_stats, get_sset_count and
get_strings operations are consistent.  Depending on how they are
implemented, a BUG_ON or BUILD_BUG_ON may be useful to check that.  I
don't think there's any universal best practice.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-wkZD5S0fdj1TjxzmNzgX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuZJBue/yOyVhhEJAQp7RxAAy+pOnHtBAtGZaxptf1I4suLFKElJGOOC
9cAH3q9ji6kfPF3/ico87/h8b/oHw9+iU/1Or0GRmsxPzl3qZ3w/aXrT51ASyPmG
l4V/GRZg1KO8bSo3cN2Oyg+QZjYyPlcReKhExpwC/uU0GKv/VuDC7TOw8o5Ledag
WGb7iBISVlo0Mh9IXqYRLVzLEyqQqckN9T1dvgjUTgWQWuBHLKVd4TFBG8xsmDcQ
TUd0ImNSlQ5xjkR3CboOXHmIlg6MqZOTwUIL4F5u8MaJJAFHXCBgKtdWEzsB+sls
OvD+gOfGtF1TxLIXOhl2UMN9Ifn8WB87Caf196NULZLNXfKeUzKKs1KUGUADDdX7
ucrNG60r+ktl1ac/3M/NerGVf6hHeml/+1oKVazvjJqgyFFLisn2tcgxE+jADhMB
6cJBAfEqlKlQOC0pgdD0/y4/im4G+I71zsn/Pevlt0AQ6hfMAxN3mfJxStDe2xfL
aszJ+ZavmZ6tz4yxBbdDrLentebvX6lhXtwjInfWv3AEmhD5d0Oz8wtO/eFhXBNq
0Nw9B6hzcutg7RL4lsSLwjeUp5mKxT4VI1+sU7/Wiw7K/GIDnPE8Dj6LQ8r9+NHx
9PJQFKLjxqk+8G7gITbYxQ0DSkAC/F/AcwPYyFp1Kp7Ac593BewT7A87WhvdW5pI
C7UALnqu/us=
=txbu
-----END PGP SIGNATURE-----

--=-wkZD5S0fdj1TjxzmNzgX--
