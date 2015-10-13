From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40evf: fix 32 bit build warnings
Date: Tue, 13 Oct 2015 12:05:32 -0700
Message-ID: <1444763132.2870.32.camel@intel.com>
References: <6607276.TY67sbLLqL@wuerfel>
	 <1444717101.2870.16.camel@intel.com> <57023416.17EujnXPCo@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qHUuMTKfSfA3031V8fEn"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	kbuild-all@01.org, Andrew Bowers <andrewx.bowers@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:25905 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752AbbJMTFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 15:05:53 -0400
In-Reply-To: <57023416.17EujnXPCo@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qHUuMTKfSfA3031V8fEn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-10-13 at 13:37 +0200, Arnd Bergmann wrote:
> This is the majority of all build warnings we get on allmodconfig
> (both i386 and arm),
> so it would be really nice to have it fixed before 4.3. For all I can
> tell, the
> patch still applies on your branch too, but see below for the rebased
> version.
>=20
> I also note that your branch is not part of linux-next, is that
> intentional?
>=20
>         Arnd

Huh are you sure you used by dev-queue branch?  I ask because this is
what I am getting when I try to apply your patch:

git am .apply/i40evf-fix-32-bit-build-warnings.patch
Applying: Jesse Brandeburg fixed a bug for 32-bit systems in the i40e
driver
error: patch failed:
drivers/net/ethernet/intel/i40evf/i40e_common.c:443
error: drivers/net/ethernet/intel/i40evf/i40e_common.c: patch does not
apply
Patch failed at 0001 Jesse Brandeburg fixed a bug for 32-bit systems in
the i40e driver
The copy of the patch that failed is found in:
   /home/jtkirshe/Public/next-queue/.git/rebase-apply/patch
When you have resolved this problem, run "git am --continue".
If you prefer to skip this patch, run "git am --skip" instead.
To restore the original branch and stop patching, run "git am --abort".
[12:02:27 @jtkirshe-linux:next-queue]$ patch -p1 <.apply/i40evf-fix-32
-bit-build-warnings.patch=20
patching file drivers/net/ethernet/intel/i40evf/i40e_common.c
Reversed (or previously applied) patch detected!  Assume -R? [n]=20
Apply anyway? [n]=20
Skipping patch.
2 out of 2 hunks ignored -- saving rejects to file
drivers/net/ethernet/intel/i40evf/i40e_common.c.rej
[12:02:52 @jtkirshe-linux:next-queue]$

Even looking at the code, the code your changing does not exist in my
dev-queue branch of my next-queue tree.=20
--=-qHUuMTKfSfA3031V8fEn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWHVX8AAoJEOVv75VaS+3Oc30P/2m+a8Yv47vvhxe3jiSEYr2i
tQzL6zrtPt4p4Ws75VAwTPvVicIoauXye5+e4OO43ue2geCZq/RwId/YlMMivADy
am7WjYZjZltNjrpoXAAz4lAcp3etWvzCf34U0Xez1SNuIWNrXmR4TDgKLggp1Xo0
bJRFBxd4NiFZ7S3SapW3wxAh6QHuhCd49dQqmbeEawnVC3i47ACmJDZBntDb48vH
/tQWwCHC1YdPYq/ZWJgO4rIZXQKs6PZ0MshoACPxj2EkiIbfKX/Cd8tE9HvN1xnU
wVeWO3VulPaS5YyVKVMeQmdJhgIZCN5UAA5xXYrA0NTWrHepemUXIimW9GEm1TGH
H8fLiUe2UqNgrgMpLqsEDt+L5vnZD1FwOnsYeGLebhrJPZwNAS+dpBljswSbFZCs
WVxDsk8hhgBCblyMI+atEFmuJKWJZfYwwVl+YXf1uXO+l7zX/qeSiJBhEHXm8ahG
pVaYx4X+nNmMOmSog35GqMiJCz3EjZh0ps1wbxjpTHKOMyKd+ypc321ILzeW9zMs
ywRqo5Tr7j1V61C9akar4WrdTi1MtqQ5B6llkt8znm2IBFUovsF6af9rghvryOzC
Yo1d7WtqtIxKiu1cP9xqvAthg7+lSNGvL3JCod1OE6XpSAStZrfUmAhcssXSAg5/
gXdwN7DeETMjm3WXjAoP
=VQrT
-----END PGP SIGNATURE-----

--=-qHUuMTKfSfA3031V8fEn--
