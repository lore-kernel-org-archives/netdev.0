From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 4/4] e100: Use dma_rmb/wmb where appropriate
Date: Wed, 08 Apr 2015 19:48:15 -0700
Message-ID: <1428547695.2729.7.camel@jtkirshe-mobl>
References: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
	 <20150409014949.4434.29969.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-C1ik0YcgzWXdhFr8C2cN"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16007 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754254AbbDICsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 22:48:17 -0400
In-Reply-To: <20150409014949.4434.29969.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-C1ik0YcgzWXdhFr8C2cN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 18:49 -0700, Alexander Duyck wrote:
> Reduce the CPU overhead for transmit and receive by using lightweight
> dma_
> barriers instead of full barriers where they are applicable.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/e100.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)



--=-C1ik0YcgzWXdhFr8C2cN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJehvAAoJEOVv75VaS+3Ot1IP/1Ab8SiwAJeUrlMD1o613AHp
0EdTlIAfK5jF/ViUwBz0ydqn6tcRcio0pp/+wqB//ks76LOhQVjoXRMyi4l0dfjg
y1mYSgLwx96iLi/+JfDYh0P95PSLc7qgsGIKj9h0ZpKpaz9skcvYiOEpvn2Mi0F/
QiLgQPgSCeAHDqMALQeyelrVIZOijTRLsf7CokqMyqL5w2fdTnN77GvyYsGiPelA
LAnEDwV6We+fY2T8r+f/P6+wFIFRyqhtRdyo7SndXeKMLX/xXeWp54rIWqXc8G2O
PJfyFZoNYUjvpRwwcPSlwYjhlEQGHmPhG20DGuk1MabImhlGKL+dwveKIKOyct2V
oiO0cbV8+9oCbn2VKr2TAR+WaNqK+hNOGKJWishohRAZWMH9+Ym0roK9B1oGIyfe
JdTk5d9aNTHhu5acGHX0dGvT+4KR2gIIMkDB2SlpODac2V1hQ8p6SHwzzcht3jxN
k+kX4IK+Q5irvhJCSVQ8Z3nrNbomaGJ32lk5FGqejuN152slhmTp62iO+1463gVi
VtxjDTr0o0ZGc+G5/felQ2DJ7MR0LpwUv4vGXVaB3GM7+tJ+6P7UMLHZaLWojF+Q
q45PHqWYLbf6XY6Hz73P+VnMBb8IvvjXZJ+dwqRwGbnGzWjQ/dVu1NhZe7lBAf9X
Zzu/CgP0kOmbiX3dwN/x
=3aFG
-----END PGP SIGNATURE-----

--=-C1ik0YcgzWXdhFr8C2cN--
