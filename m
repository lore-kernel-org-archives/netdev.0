From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 0/4] net: mvpp2: fix the mac address retrieval
 logic
Date: Fri, 25 Aug 2017 15:58:48 +0200
Message-ID: <20170825135848.GA31512@kwain>
References: <20170824094658.1296-1-antoine.tenart@free-electrons.com>
 <20170824.214624.250495333472785242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: antoine.tenart@free-electrons.com,
        thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824.214624.250495333472785242.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, Aug 24, 2017 at 09:46:24PM -0700, David Miller wrote:
> From: Antoine Tenart <antoine.tenart@free-electrons.com>
> Date: Thu, 24 Aug 2017 11:46:54 +0200
>=20
> > The MAC address retrieval logic was broken and when using the PPv2
> > driver on PPv2.2 engines I ended up using the same mac address on all
> > ports. This series of patches fixes this, and also tackle a possible bug
> > when defining the mac address in the device tree.
> >=20
> > To fix this in a nice way I ended up using a dedicated function to
> > handle the mac retrieval logic. This can be hard to backport into stable
> > kernels. This is why I also made a quick fix which is easy to backport
> > (patch 1/14), to tackle down the PPv2.2 mac retrieval bug. Let me know
> > if this approach is the proper way to handle this or if I should do
> > something else.
>=20
> This patch series doesn't apply to any of my trees, that is the first
> thing.

That is very strange, my patches were based on top of net-next. I'll
double check if they apply correctly before sending the v2.

> Secondly, this is a bug fix, and the bug exists in the 'net' tree.
> Therefore this patch series should target the 'net' tree.

OK, that's the question I was asking. I'll resent everything to net
then.

> Please always target legitimate bug fixes at the 'net' tree, rather
> than 'net-next'.

Sure, will do.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmgLRUACgkQXE2LyK3b
vNj2yg/8D2lkafDtet2n8n/m+KMUXVhIN+g8ZEEv583ej5yeLmXS/XUjGYIyi7rl
+EjsMWEVzrLWvMPxOVEaKDQ1QDluq3TkuEqscVYRUskH4zXnqpZ56pxtIYGUFHRK
nfyw8FvCWnd2/e4Ug01O/pBrXGtNAjiv56U0AET4M9F/iaPRAN4K8gw9Pkes2en7
Jisrrqj8EMSfovKNX6Wm8r6m9ardpzcUNvxS381CYYPvsXo1SsyCsLpkfhpFmEg1
WKffpXvwNDqSeTVesaG6ytYzxHyQxw/jrQ6J+H0NOp/64OyI5lMzlXD7mwEiUJzd
57qpwgVrtK+z1rkh7U0snzne6uzhbM+b6rPQ4zZAae+120CY+fyzM4ujyv4jrIp5
1bLGjTFSSlf9BoWys7ICHUtv/Tq7nKXDoYwhVjz26v2BkkdaDY2qDo3HaTsqrgaa
CEFSyJym9+exlIi+6z6AunQkiDaVkWL5QIeeSz2iIqF6yCgQB7GIy+tZn1UuYH87
A9R7YXN6JQ0TFdSwzAIgHMyXxNJSmNmHwuGkg1zOPOXAwhDB2vKIda+AM8Z2MWjt
miKZUeLhRyS6kDdFwf9Jf2KWed0DaZvGasivRi/FpNP9819mk0SatZQDKf/xnklP
5LctQbHw0QXUiiBbYQ/6yut4Kcl1eI72CLMUkniXWW2Kmr/Nze0=
=iLh4
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
