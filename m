From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [patch 0/8 2.6.32] CVE-2010-4251: packet backlog can get too
 large
Date: Sun, 13 Nov 2011 23:29:09 +0000
Message-ID: <1321226949.3059.13.camel@deadeye>
References: <20111113201336.GA1362@elgon.mountain>
	 <20111113.155851.2167389434844487922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rNxSP/fVTWbNjPt9PlfF"
Cc: dan.carpenter@oracle.com, stable@vger.kernel.org, greg@kroah.com,
	netdev@vger.kernel.org, yi.zhu@intel.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58220 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750870Ab1KMX3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 18:29:32 -0500
In-Reply-To: <20111113.155851.2167389434844487922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rNxSP/fVTWbNjPt9PlfF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-11-13 at 15:58 -0500, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Sun, 13 Nov 2011 23:13:36 +0300
>=20
> > This patch series is to address CVE-2010-4251 for the 2.6.32 stable
> > kernel.  Here is the CVE summary:
> >=20
> >  "The socket implementation in net/core/sock.c in the Linux kernel
> >   before 2.6.34 does not properly manage a backlog of received
> >   packets, which allows remote attackers to cause a denial of service
> >   (memory consumption) by sending a large amount of network traffic,
> >   as demonstrated by netperf UDP tests."
> >=20
> > [patch 1/8] introduces sk_add_backlog_limited()
> > [patch 2-7/8] change each network protocol to use sk_add_backlog_limite=
d()
> > 	where appropriate.
> > [patch 8/8] renames sk_add_backlog() to __sk_add_backlog() and
> > 	sk_add_backlog_limited() to sk_add_backlog().
> >=20
> > The patches mostly apply without changes.  The exception is:
> > [patch 2/8] udp: use limited socket backlog
> > Then the rename [patch 8/8] needed to be changed as well to match.
>=20
> These changes are way too intrusive and potentially regression
> inducing for -stable inclusion, especially a kernel that is in such
> deep maintainence mode as 2.6.32 is.

Debian 6.0 based on Linux 2.6.32 has patches #1-7, except our backport
of #2 (for udp) looks a bit different.

Apparently several other distributions have also applied these.

> Also, I tend to personally submit networking -stable patches, so please
> do not bypass me in this manner and instead recommend such submissions
> on the netdev list so I can evaluate the request.

But you've previously said that you are not submitting networking
patches to the longterm series.  Did you change your mind?

Ben.

--=20
Ben Hutchings
Never attribute to conspiracy what can adequately be explained by stupidity=
.

--=-rNxSP/fVTWbNjPt9PlfF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATsBSxee/yOyVhhEJAQr0UhAAyX/tBlZ1fY8GIUImyBMGBXq2E5DVIAEB
lmyKzgnTSEb3UrihZkvZfuafk2UGfqTLNfilUFSMN/R/1DhGv73lcEtL0YTYJU3X
/erifTpn4D4Xc6SdXqS9smv03LPl/Rvcg5qFETx0BHT3dsteTPxuggX8bi81mk4B
JY9zLiTIiIU30c5mWv/tTP9VfTusOvRl1vcQG7A1E7OGggmy30YlhpsgYZln8MI8
NQEYu7pBuH8R1SoJydECY8sFW6++qEKEoTPUaZ1fvlVXEXi/sy8HPu+6VtacwzAH
MNeElP8uAwgbktMFfjRkbArERnayV4NozDxjfZ6bZiJiMbyoCziSq6wOuP46W6JS
MNhVYaEaIVxmKBxfjFy3A9jSlegotnPH+LJHXRAhZ1mLcXj8r876AQdxt7PNkXZ0
zuRiXV4nWlIsNoFNxKWDjgDNwYseybBEFmr1lPtx5dudBKoFf1CKLJPEH4xwo9DF
NgkThq00WErSKwceh12zCBD297MWy11hGNHD7DyjoyONsasexaY9MmCP7IWfEBIe
DFb4HS+u6GxecHu6yb+zsqHqOdoSjaLxFeBrL9tY7H81w7x8g2l342XW0hIvvegr
7Vp9IINJ2xms8/ebrsQSgGajRKin9CuFDHhHwNgDs4OoHfPdVhwqvQayaj1O1qS2
iXtpzYd/ovg=
=3SuW
-----END PGP SIGNATURE-----

--=-rNxSP/fVTWbNjPt9PlfF--
