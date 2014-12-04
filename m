From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e / igb / PM: Eliminate CONFIG_PM_RUNTIME
Date: Thu, 04 Dec 2014 08:50:03 -0800
Message-ID: <1417711803.2404.1.camel@jtkirshe-mobl>
References: <2389302.4ImTL0YnUc@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-N5sAahnPKnYjkWl4ycK9"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Linux NICS <linux.nics@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux PM list <linux-pm@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2389302.4ImTL0YnUc@vostro.rjw.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-N5sAahnPKnYjkWl4ycK9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-12-04 at 02:15 +0100, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
>=20
> After commit b2b49ccbdd54 (PM: Kconfig: Set PM_RUNTIME if PM_SLEEP is
> selected) PM_RUNTIME is always set if PM is set, so #ifdef blocks
> depending on CONFIG_PM_RUNTIME within #ifdef blocks depending on
> CONFIG_PM may be dropped now.
>=20
> Do that in the e1000e and igb network drivers.
>=20
> Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>=20
> Note: This depends on commit b2b49ccbdd54 (PM: Kconfig: Set PM_RUNTIME
> if
> PM_SLEEP is selected) which is only in linux-next at the moment (via
> the
> linux-pm tree).
>=20
> Please let me know if it is OK to take this one into linux-pm.

Yes, that is fine.

>=20
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    2 --
>  drivers/net/ethernet/intel/igb/igb_main.c  |    6 +-----
>  2 files changed, 1 insertion(+), 7 deletions(-)



--=-N5sAahnPKnYjkWl4ycK9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUgJC7AAoJEOVv75VaS+3OhagQAKC2oVQr6pfJKePHVYr1+0VM
gVtoyKJ7xfG6/r3kWBbYOwqnMIHmwZNYAIsECLiWJVBRTyisCqIe9jI9PFnZV0Hh
zvVQgtiPkN9IOd1EiF1XzO0JUXLXxZquTxZxLPlzdHQNDxmrJX4HhEIAyT+o5OL2
qvAguBKU7cS9N7OIGgptOkhj4QPm8b4BaertLgv6tpaYFBqdCfGzO0MEAdJfAPbK
6NvllmaR0xnufjZhmWSE8k4Ad8cFfkhIaEe+LgjtOcEC1ic962gDMh+LXmOcMy7c
moKxXCnFXr1z5lQJUwZ9py0aKOtOj/5WalAQM9OfniOkyMLYGt8kuF2m5Wlyun4o
vni5aTl7JzOQkEC6yN4qFki2jIE6fbCesOcPaBK08J0rjr8XN7WA5WqTNxl8tTFt
+Ldlc0wXAaDXaVuvtSj/oUex/RYdO7aNatvCwPuUH/e/zfAPAHVyBdllq8rdgmH/
FeTJ4Z4CtyIGQV+M7FVxFcj9nNkJiZDr3b15HTs8WhaYKZtNSVfJxsga7xn0zmc4
4ncOZgRF+9PeGdMvnzGU0Kgix//j9gxsUXXnTm/qktj0gwaiCH6JCdQlyETlywXj
hmFlvzF28FEwPlliCfnz+C9Il44HYFfPQAiAwHeK/DECvN/EHILGT0tocM6Y/PkD
rDoiBOB4uj6i0SLMf7jd
=sAzl
-----END PGP SIGNATURE-----

--=-N5sAahnPKnYjkWl4ycK9--
