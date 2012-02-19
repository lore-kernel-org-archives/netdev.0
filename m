From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH v2 2/2] adi: adapt to eth_hw_addr_random() and changes in arch/blackfin
Date: Sat, 18 Feb 2012 21:47:01 -0500
Message-ID: <201202182147.10920.vapier@gentoo.org>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de> <1329521263.584.50.camel@joe2Laptop> <201202181428.07491.danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1915165.d0OskjkLuK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bob Liu <bob.liu@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201202181428.07491.danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1915165.d0OskjkLuK
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Saturday 18 February 2012 08:28:06 Danny Kukawka wrote:
> On Samstag, 18. Februar 2012, Joe Perches wrote:
> > On Fri, 2012-02-17 at 18:15 -0500, Mike Frysinger wrote:
> > > On Friday 17 February 2012 05:57:54 Danny Kukawka wrote:
> > > > Maybe. Many drivers already print information about setting a random
> > > > mac address to a netdevice. Some with printk, some via
> > > > netdev_warn/netdev_info/netdev_dbg or netif_dbg and other with cost=
um
> > > > methods. I could unify this, in a next step with a netdev_info in
> > > > eth_hw_addr_random(), if it's okay for David.
> > >=20
> > > i think unification in the core makes sense.  it enforces consistency
> > > and removes duplication.
> >=20
> > It's a good idea.
>=20
> Okay ... I'll send a patch to print a message via netdev_info from
> eth_hw_addr_random() and to cleanup the drivers.

thanks!
=2Dmike

--nextPart1915165.d0OskjkLuK
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPQGKuAAoJEEFjO5/oN/WBfgYP/3q2g7dEfFDv+cUOZWXfOFZ9
uFWNv1I8v6kRHhIKSdpEydJMA+MBEi5DXoJmuAsIlX+GWqbxCIIAv4yMR0PHpU+U
hUTi4zt3HcSLY79rG+x2vwuFVdqJA/GRQcK5HVAuGLLg8SxPZwOKv5OMUF6klZyJ
p0oKWvqFxfdewKN4fW4Y8MmM9HZheDDunJyDPBrZGzGmCy9UzrLa9NP90vCZR/IJ
ggAaXtutCX1F5WqZsx0EaM3ltO9+ZdsM/nSKIBe+P3bF9FHmtKRXHHwayE6RzQig
u07xjqaZr17uaLvrePg4SZuCUhsBJp75dHayF0t69UveFvS5zrK7j9/eSECznDve
CUd0r6yysPcXnK0XKbiFYspoQFJ/vqtQPkxt1Inmud3XRAI8O58Y7g/Y/FzPDR0P
RCeDC9nIvdA3yvBxTlzIUaiaRLG2FBVbC7wxHsCH42BvNEABHQsMOmzK1qoaUOEj
JtPwwmwRCk/mApXJqAsU+skheyM2SXzfKB6GfiZptYef/FRzgGJGWeyzC6ProBOy
q4tCH/uriHEetyagPk2UwG90i1Z+o+axB3iljIidzM6v9dT4F9j4E7MQhDfHzUUh
1ZCJBlM3Wnh4N5L87Z8XAOg5+iJeYBkHT4Kjv1lp3XQPD7Uhw+MivdxAQHUxQ6Mr
q9ZOGy4q+6c1ujhcBJc4
=G3EI
-----END PGP SIGNATURE-----

--nextPart1915165.d0OskjkLuK--
