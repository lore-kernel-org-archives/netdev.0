From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net: i40e: avoid unused function warnings
Date: Wed, 20 Jan 2016 15:36:03 -0800
Message-ID: <1453332963.2958.39.camel@intel.com>
References: <2806620.EpZqDlZTO3@wuerfel> <8814508.SjLecHrQqA@wuerfel>
	 <1453329885.2958.32.camel@intel.com> <6894276.2dlRmisKUo@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YYSWXs7SlrtGA43Hsfl4"
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>,
	intel-wired-lan@lists.osuosl.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6894276.2dlRmisKUo@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-YYSWXs7SlrtGA43Hsfl4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-01-20 at 23:54 +0100, Arnd Bergmann wrote:
> On Wednesday 20 January 2016 14:44:45 Jeff Kirsher wrote:
> > Yeah, I have a fix for that as well.
> >=C2=A0
> > You can confirm by pulling my next-queue tree (dev-queue branch).
> > git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-
> queue.git d
> > ev-queue
> >=C2=A0
>=20
> I checked out that branch, but still see both warnings in that one,
> plus
> a new build error in igb, which I don't see in linux-next:
>=20
> drivers/net/ethernet/intel/igb/igb_cdev.c: In function 'igb_mapring':
> drivers/net/ethernet/intel/igb/igb_cdev.c:150:2: error: implicit
> declaration of function 'set_pages_uc' [-Werror=3Dimplicit-function-
> declaration]
> =C2=A0 set_pages_uc(virt_to_page(ring->desc), ring->size >> PAGE_SHIFT);
> =C2=A0 ^
> drivers/net/ethernet/intel/igb/igb_cdev.c: In function
> 'igb_unmapring':
> drivers/net/ethernet/intel/igb/igb_cdev.c:275:2: error: implicit
> declaration of function 'set_pages_wb' [-Werror=3Dimplicit-function-
> declaration]
> =C2=A0 set_pages_wb(virt_to_page(ring->desc), ring->size >> PAGE_SHIFT);

Oops, I just realized I had not pushed my latest tree to kernel.org.

The igb issue still remains, I am working with the developer who
introduced the issue. =C2=A0Looks like the i40e issue about possible
uninitialized variables still exists. =C2=A0I thought we had resolved that
issue, but apparently not.

You should see Eric Dumazet's patch on the tree to resolve the other
i40e build warnings.

I can add your second patch to resolve the uninitialized variables to
my tree.
--=-YYSWXs7SlrtGA43Hsfl4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWoBnjAAoJEOVv75VaS+3OOrgQAIyHEk7JvQl2MUVayyhru5Zj
JjOZ+iPn2VWqJyIfBIwDrVyk3CkDSCcJzcY+OsT5AcbQAtgd/HmK/ekrCl/nZJ3E
iKg2b+rRfqyT1SnX9foftv/H2sN1G6Bj2u03LKs2HUmeCPonaNfE7SNICQtQXRVz
7xEJJeFMNMTO4lCiHkqxdzVM+bpxGRL+C0Lww+knJzrTCIX1O0W1b51zGKbI89SO
JVFxNZoYu4nwGcdGvJyG8MXLinKurM/X2b89PtAYjJLv4RIl+fCENMgzSbYjms08
QxTpaV8Y6Ze7+kdMHJbi/P9oor0n3k1JYsmjaaP9EPTaJnWVjAW0E9H6klqdgSfZ
hGf6s0r66eDbeyehWJjx775AAYk6JbOw32GELATbdV3DY/np9qY953JnnlCl4WJ/
oDnqihnD9AnFhp7eDGgAIigXCnkICGGzR2SMghXwrzSpkeP0/irFm8NsB1+JJtdo
ElPOXMo1DGpEGeGa0msSuYvc+6qna8zKrFz08/lCPve/xJxTK5mbXvyM9RyvOTxY
nkdcOJQZAi6UwT6D4av+Gur8xnnAz2HYnQVWhbhq+d5CjeF2I/HNiKkt1mpiQiO6
UjoYwmD+RzXdX9SJFXZCOtlTXhzr16+WJtspS5cTQfOtNOi5eNhwHzVSy4+ovfXo
FSoB1msU4U+MTYk+srI2
=JrvJ
-----END PGP SIGNATURE-----

--=-YYSWXs7SlrtGA43Hsfl4--
