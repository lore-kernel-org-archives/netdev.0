From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next-2.6 PATCH] Fix IPv6 GSO type checks in Intel
 ethernet drivers
Date: Sat, 23 Jan 2010 14:52:55 +0000
Message-ID: <1264258375.373.53.camel@localhost>
References: <20100123092430.11188.13968.stgit@localhost.localdomain>
	 <20100123.012723.129767377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-wJ2OoFtXXPhlbjop04yX"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sri@us.ibm.com,
	David Miller <davem@davemloft.net>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44093 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752801Ab0AWOxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 09:53:44 -0500
In-Reply-To: <20100123.012723.129767377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wJ2OoFtXXPhlbjop04yX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-01-23 at 01:27 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat, 23 Jan 2010 01:24:45 -0800
>=20
> > From: Sridhar Samudrala <sri@us.ibm.com>
> >=20
> > Found this problem when testing IPv6 from a KVM guest to a remote
> > host via e1000e device on the host.
> > The following patch fixes the check for IPv6 GSO packet in Intel
> > ethernet drivers to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
> > when packets are forwarded from a guest.
> >=20
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> This is definitely net-2.6 material, the bug definitely exists
> there and besides the ixgbevf bit, this patch applies cleanly
> to net-2.6 as well.

This is presumably suitable for stable as well; if so, please cc
stable@kernel.org.

Ben.

--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-wJ2OoFtXXPhlbjop04yX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS1sNQue/yOyVhhEJAQKobg//eE20Ph0/XixELvSA2twyiNAQez0ln0Pj
YvsFHVK8zTC+I1tYB7UUvXFN35g3Eh9zfORNzsp1xGMrslcZQSaalMkeCThu16Nn
cYwPYh4oJnBzn5ySBy2Bca6tQ9fJ1jBlapxwEal0inv7sEJZH11hV2Jcb/cHD/mh
TIGXWeBr1bFdSsQGkue/Kg8OKFuSv2YMI6XNZqgaNlcvFzwUF2u2v4sEgmhZ2vYr
U9MOAOx3I8dfQvNqnY8/gFlgASUAVaoNhKpamjyM8jspRzcOkv18ZpHj392ZAeJs
CMOzXQGLOUgl5adGW6VueU6hvXfmfKxSqrQUZl1UMaQ4XU3bKu2ha9z+HBzrWuVi
vH7di70BghJtVS4UH5PDGzz54fGX/GBNjhK0cbPUZhsZCdmGwb3bI9BHbwqwMeo1
8K6bAec0sE5VW3DwJDYIq98OYZDntKV/3PWNhMlz1K7+eE+u8CII3MDJJBt/d9Y6
KA1YgnLBkuFOR/tU76o54KI/WhZz/LUjinfJmqCrw5dMcAj7c3txO7LYr/1Wc5Ny
Qvmi+Sw9OoiLcIx8Et2ttH+xmIqC6MJFhzMF9jTkzAf3/XJUgI8mcvny+BRtyNqM
FJyGDTRVc6K/NTbgKNd7GHXxOlK+/KQeHzulkePkUTqjNcb/PbPMKgOOTZRGvM4n
1/48x7wbW+U=
=ed6h
-----END PGP SIGNATURE-----

--=-wJ2OoFtXXPhlbjop04yX--
