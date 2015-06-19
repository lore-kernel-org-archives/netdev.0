From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] fm10k: Report MAC address on driver load
Date: Fri, 19 Jun 2015 02:15:56 -0700
Message-ID: <1434705356.3530.82.camel@intel.com>
References: <20150619023812.1345.75383.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bgrURilgR8gg13ThuFuO"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26947 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754465AbbFSJP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 05:15:57 -0400
In-Reply-To: <20150619023812.1345.75383.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bgrURilgR8gg13ThuFuO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-06-18 at 19:41 -0700, Alexander Duyck wrote:
> This change adds the MAC address to the list of values recorded on
> driver
> load.  The MAC address represents the serial number of the unit and
> allows
> us to track the value should a card be replaced in a system.
>=20
> The log message should now be similar in output to that of ixgbe.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>=20
> v2: Moved printing of MAC onto separate line similar to ixgbe.
>=20
> (Hopefully this works for you Jeff.  I took at look at the patch and
> just
>  moved the bit I needed down.  I figured since this block hasn't
> changed I
>  should be able to get away with just doing this instead of pulling
> and
>  rebasing off of your tree. )
>=20
>  drivers/net/ethernet/intel/fm10k/fm10k_pci.c |    3 +++
>  1 file changed, 3 insertions(+)

Works for me!  I have added your updated patch to my queue.

--=-bgrURilgR8gg13ThuFuO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVg93MAAoJEOVv75VaS+3Oc5QP/jX4gRJD1TWnRDAKMv1lWnUG
Bizl1hsNkPZUCWryjYWc418/5HwcowUKkuy6e0gz7ksjFPk0r6qgulUj9tiq+yCk
0cMjoikc1DWkwjbCZsOXTaVx7xLFFbll5aM6Iz/U2vbM559FkT84vXgpnNYmGIty
Ue/o5xsD4kf1Yi0JhwpwYGcIfCI19Wyn0YpllzZIpP7K3/uNSVL8WIZJQjBkBoF0
PJtLqM0GwnK2DyN1OHlmBiswvWcFX4djLZTZeULLR9bmyOlsa0lPR7A7yHCz5POX
CCd3zJRw9K7W76XkPD/YQW60udOgy/9upqM/JOGp3ykINSfS53k4Bvh1+fOQ9BCz
0qxRTSlw0tSaG6F5ui/iRy8VinKEnXLP8WvqjwjWpjoTrjDXs0epNoqsIkOYE6YM
I+TBpuy9jJ7a41eWHb5SWEhDRI+fGIxqyFuR8o/ozT6ozxhccFWvB0k+prUK0+5q
MBfhq9LyT1fCLRKXDrgLJVNh07vit2jaX1fxdDD1nCCIIkYNJOYKdSsdBWUJD6x4
qdmaqVAzAVA1sp8TnuH1OxeE3N6n8anV+2ERJUbi8Z+ikZCrjhNELoNZ6ZiTs1VW
HlEoyVKEFE7sqaHXbb98886nI52DSqq8iMXWKJDrHxi4oa62c/xvf+rvSsPscs93
xCJH/WiriEOzZ97Cg4D8
=KmYV
-----END PGP SIGNATURE-----

--=-bgrURilgR8gg13ThuFuO--
