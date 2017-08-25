From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net v2 1/4] net: mvpp2: fix the mac address used when
 using PPv2.2
Date: Fri, 25 Aug 2017 16:29:28 +0200
Message-ID: <20170825142928.GB31512@kwain>
References: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
 <20170825141420.14027-2-antoine.tenart@free-electrons.com>
 <20170825141939.GB30922@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="hHWLQfXTYDoKhP50"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825141939.GB30922@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Fri, Aug 25, 2017 at 04:19:39PM +0200, Andrew Lunn wrote:
> On Fri, Aug 25, 2017 at 04:14:17PM +0200, Antoine Tenart wrote:
> > The mac address is only retrieved from h/w when using PPv2.1. Otherwise
> > the variable holding it is still checked and used if it contains a valid
> > value. As the variable isn't initialized to an invalid mac address
> > value, we end up with random mac addresses which can be the same for all
> > the ports handled by this PPv2 driver.
> >=20
> > Fixes this by initializing the h/w mac address variable to {0}, which is
> > an invalid mac address value. This way the random assignation fallback
> > is called and all ports end up with their own addresses.
> >=20
> > Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> > Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences=
")
>=20
> Is this patch alone sufficient to fix the problem?

Yes it is.

> Ideally, you want a minimal patch for stable, i.e. -net, and a fuller
> fix can go into net-next.

That was my intention (providing a minimal patch for stable), and I
asked about this approach in the v1. Dave told me to resend the series
to net. Maybe my questions weren't clear enough.

So probably the best way to handle this would have been to send 1/4 to
net and 2-4/4 to net-next (but then there's a dependency between the two
series).

Let's wait for Dave's answer, I'll respin if needed so that it's easy
for him to apply it.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmgNEgACgkQXE2LyK3b
vNi9Jw//dO0a+CmHfCRDXFddhgTx42J7FBM4MNhX6KGZwPdqrATL/wlDAIzvxJGZ
IwBeiLO/BlnYw9J/VtJdeKWCl+s4c59VToq5aeF3yFWTbrqYtlaOH+D8OjsBWZ7b
zbqMguRSIp1y6jK1d0pl09TXPhqZMGqJ1J1UMNHgWdt1DekpOX6S45rr1Q3ozRvc
CB9+7zrz6mgpSIiJFOLQmdTZUJ9+VN0PSlhMMg3OYSkKJzaJO4qnuY7WbWtkiQRh
NmPyY6XHCxwbIJj35YzPbbv9sdXHaPBfjrTqgv2zn+2dE8cHt9Epvkc4sxHGVO0Z
n/uxUwbFlNQ4ndXxDjNG9sc1wvAc7U6nnSyyzPCGcaLaz0Vczf+817U7itep4lbA
ceQdU5LO+JrTFsZ8L2Sgm9HhHw82vVPUH+U7b92fmpJ3gjEBwr1xE3rPZlHR8p74
PoZ0fIyvWj3TXMsZvjbReoy7huf4MvUatNai6ddAe7NNuAto603rhVLcU/aQweAD
O5MD7xNSIMKvSi0Gde8CyjyuufAOWD9sqvII1hU6JOOn4UTUWHuWMIDWnfCy4H2B
FPQKdGSZwlQXGqwaTWbHFz8L2oo2jksxMQruEvzfsbDu9ogCbJDMXvGOFxFCNuqC
LEdNQqZlViGL+IwI11Bb76k/2FKsepK7ZwT9D1XZZxl7kUCcDhU=
=6K9u
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--
