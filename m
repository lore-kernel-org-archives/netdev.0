From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 21:05:42 +0100
Message-ID: <1203969942.13162.151.camel@johannes.berg>
References: <47BDBC23.5080007@trash.net>
	 <20080223.200202.255773165.davem@davemloft.net>
	 <1203933228.13162.58.camel@johannes.berg>
	 <20080225.115220.02432174.davem@davemloft.net>
	 <1203969403.13162.147.camel@johannes.berg>
	 (sfid-20080225_195704_896688_562D4BD9)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cneBcGvCIPousr3PmhQG"
Cc: kaber@trash.net, joe@perches.com, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41899 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbYBYUGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 15:06:09 -0500
In-Reply-To: <1203969403.13162.147.camel@johannes.berg> (sfid-20080225_195704_896688_562D4BD9)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cneBcGvCIPousr3PmhQG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Mon, 2008-02-25 at 20:56 +0100, Johannes Berg wrote:
> On Mon, 2008-02-25 at 11:52 -0800, David Miller wrote:
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Date: Mon, 25 Feb 2008 10:53:48 +0100
> >=20
> > > Maybe we should just add a new printf modifier like %M for MAC
> > > addresses? Then we could use sprintf, snprintf, printk and whatever w=
e
> > > please without any of the macro stuff...
> >=20
> > But GCC has no idea what the heck it is and will warn.
>=20
> No, I actually wondered about that too and finally just tried, it simply
> ignores it when doing the printf warnings.

Wait, no, you're right, I had the wrong warning flags enabled :(

johannes

--=-cneBcGvCIPousr3PmhQG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8MflaVg1VMiehFYAQLY7RAAl5t8fpCTTZ6TRrSmX8VUKdCI+6RDOU21
FmXWXi6q+grTtlvtq/oPtUwZxJi464neaXja5/ZLk2tqIJQhAN53dn3NzPO7xQPs
UnB4u229FkQI4BhPruMg4Zg6FlULZ9YclrHhcxnMKAccm+yXfN1/nAZ316Kzg9gz
QCJxjyyeehG+UaAdd5nq2ZvIsZboATW+YK0SJzV02/t1SU7NOz7kownFIMocEsMc
tNWp+E51Y66qsPkBwDBd6DHP62Erz4PfLQ9Fz9zeE1Ns2SPWkbWTIx0WpmAZIQ05
7X1Mx5nivO4kMVAoq/2loXyik16h7ZOm4pa5H0JUC8AZHFFj689KpyGQ0b4ebOGR
dIwipOCRBajF+kg2VaHlLfqB8WGnraZcbh+cCIjSD4UvN83rdLlfhSAmQdQSAGLW
FTNsAUWaSluvPnp++iTITvuD7S/HNDZX+yMCX382HJC30bCy9ecewM8T8QRYrbbJ
5Q5HN8umkCij64CA+aTEU9Y9dwKpY977HezUWmNWF1YguQQu++aOCZlQslb5uSjy
xIjuNXrhKHbZJ0ShoOH1tEi7FV6YKPiJbsVnRNn/prDpJAhC/XRal1yZjeIyrGDN
pbHZGNlzc6F6DxcbyhCr87ie5HrW03sBXG7Wj+Z6SbVgzgAnAUjPaKRI9gE3Wys8
4lnZM/VO8K4=
=jaDn
-----END PGP SIGNATURE-----

--=-cneBcGvCIPousr3PmhQG--

