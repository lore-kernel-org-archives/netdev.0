From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40evf: fix 32 bit build warnings
Date: Mon, 12 Oct 2015 23:18:21 -0700
Message-ID: <1444717101.2870.16.camel@intel.com>
References: <6607276.TY67sbLLqL@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OM47u+OM0BWHgVgv6EtR"
Cc: intel-wired-lan@lists.osuosl.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	kbuild-all@01.org, Andrew Bowers <andrewx.bowers@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59586 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583AbbJMGSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 02:18:25 -0400
In-Reply-To: <6607276.TY67sbLLqL@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OM47u+OM0BWHgVgv6EtR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-10-07 at 22:13 +0200, Arnd Bergmann wrote:
> Jesse Brandeburg fixed a bug for 32-bit systems in the i40e driver
> in commit 9c70d7cebfec5 ("i40e: fix 32 bit build warnings"), but the
> same code still exists in the i40evf driver and causes compilation
> warnings in ARM and x86 allmodconfig:
>=20
> drivers/net/ethernet/intel/i40evf/i40e_common.c:445:68: warning: cast
> from pointer to integer of different size [-Wpointer-to-int-cast]
> drivers/net/ethernet/intel/i40evf/i40e_common.c:446:71: warning: cast
> from pointer to integer of different size [-Wpointer-to-int-cast]
>=20
> This applies the same fix by removing the broken code.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Does not apply at all to my next-queue tree (dev-queue branch), my
guess is that this is already fixed in one of the patches already in my
queue.
--=-OM47u+OM0BWHgVgv6EtR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWHKItAAoJEOVv75VaS+3O/HsQAIMZwoGba2wvUdri+hJ89yPK
S3DODKpcn31Hg1CucHaRaQNqhvjNVjDSwjvH9DyoOAIrE3fCGnllr3pjq2cfyU3R
E0qfSHJ64dAvzcipvzrk0U7J1hMbyWYtdzzJLjsE5e6ynQ4VQn7dixoahBf6ouSF
+5tb486uc7ArH65rkV0WqxfP/+Vj42KXACf4hIZeZoVgUzduWtKIgJ6FqOVKN1f1
LhODkzl4R9HmwOTqg8+z95YV7j04yF7kMjc11fqRX1ytCSAZWEZOqVZumhESG4oc
LNvRBakVwTXfWsv0fVcsjEd/UcrJeeVo1H3s0fzi2tiFsNlh8tqmkkQE/5YXZ9S/
f6bmGLPAmuqqZO7U6pOktYM5ljgsc1/fRfbkfSzw62LxGSILBL25SZsu2poF7Qb3
KKTevZKiRV4ok3X2jrpmPBANqxTeQCYX5T565Aiq7AyRGJTI0wWNfz/b6xgYegf9
TMNsM3IBMkFUFBHRnMg5C/po3k/jELmEblhaY+GWgndROG2623XYbIm4JgfRvKpU
2WLBCQ9Plcpxd8zVAoJfHPgPgw06PLpFgkKX8FJWJ24Z3Zm7BjPKnec+jg3ZvRDC
n6K08SFSLHGyX8egwFUqqAgyrh6eLKCW0o5AfXKJnjrEB3RqtiZF4rbwchGgcOS2
UHVpYjsHsJHfYy/JcF3f
=wvUS
-----END PGP SIGNATURE-----

--=-OM47u+OM0BWHgVgv6EtR--
