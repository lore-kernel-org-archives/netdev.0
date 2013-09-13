From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [patch v2 -stable] igbvf: integer wrapping bug setting the mtu
Date: Fri, 13 Sep 2013 05:39:44 -0700
Message-ID: <1379075984.1995.9.camel@jtkirshe-mobl>
References: <20130913122927.GA31819@elgon.mountain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-V4sA63ToewYOBz/k4ftM"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130913122927.GA31819@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-V4sA63ToewYOBz/k4ftM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-09-13 at 15:29 +0300, Dan Carpenter wrote:
> If new_mtu is very large then "new_mtu + ETH_HLEN + ETH_FCS_LEN" can
> wrap and the check on the next line can underflow. This is one of
> those
> bugs which can be triggered by the user if you have namespaces
> configured.
>=20
> Also since this is something the user can trigger then we don't want
> to
> have dev_err() message.
>=20
> This is a static checker fix and I'm not sure what the impact is.
> ---
> v2: reformat and also remove the dev_err()
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks Dan, I have added your patch to my queue.

--=-V4sA63ToewYOBz/k4ftM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSMweQAAoJEOVv75VaS+3OXGkQAJH6h2MjI6HWqoOY/Az1qrsb
TuA0KCm3DjH1QN1QwVv70K9V4wAN4JibNFEX3QlOsSFJBG8L0edgWK8M7xuxEOwq
S4cj/n+T4v5RsfBhXcIF/SvIl5CgB6w6cy/uJEL0AQAwJVL8uX81s5LxhadbRch5
a8BA2KgPNTI/gezqW7imwQg7VQBjTFru69u/K2baKsdcYesae9tScxdIi8qNvgGz
ZAK3PVnqOCDG++gKsgjwX+bEnYBKXM9h6+O19Wsv2eJHMBsd0Ob+5VL7qRedCbUj
QpUYRuoPPU67N1+imGbx9nq69zbuZjexmiqVPVMEloWDvkvkI0fmgkRvaCn1+G7Y
KdUM3elE53/HgaxEezYeVjSG27gPolSFyU69wRAT6oabRn8RnGDM9wKmBFHxXoX/
Vxi8xJwMCLSSNRzFGDEPoqGUD4AUJ1m9BKGoNxliDwhAzWSPUDPA10phzCy/yIht
U5DWosKKR4QKbieVcMYvgk+kAhV62v3qGE0svxWj8xemN5UMJ/nSJzaODK+wKpCr
h88z+01elDk790Z4xUfjVBZ5JjwB4mtmusMv5u/fNgxw2woNL9E8z9b25Jnn9IVZ
aruSsIGj0Ik+maX20MLk5pog7sH0cYk5bfF/xbFvrJFNNt8nHgb5eqkXxS86Rt8B
qQS2EpkD1MKU8mX0Xwok
=BiXj
-----END PGP SIGNATURE-----

--=-V4sA63ToewYOBz/k4ftM--

