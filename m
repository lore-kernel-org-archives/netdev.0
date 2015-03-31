From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v10 1/7] if_link: Add an additional parameter
 to ifla_vf_info for RSS querying
Date: Tue, 31 Mar 2015 00:34:56 -0700
Message-ID: <1427787296.2497.109.camel@jtkirshe-mobl>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
	 <1427740529-9605-2-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5m57APBqGel4X2vTI7wT"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58603 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862AbbCaHe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 03:34:57 -0400
In-Reply-To: <1427740529-9605-2-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5m57APBqGel4X2vTI7wT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
> Add configuration setting for drivers to allow/block an RSS
> Redirection Table and
> a Hash Key querying for discrete VFs.
>=20
> On some devices VF share the mentioned above information with PF and
> querying it may
> adduce a theoretical security risk. We want to let a system
> administrator to decide if he/she
> wants to take this risk or not.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  8 ++++++++
>  include/uapi/linux/if_link.h |  8 ++++++++
>  net/core/rtnetlink.c         | 32 ++++++++++++++++++++++++++------
>  4 files changed, 43 insertions(+), 6 deletions(-)

Thanks Vlad, applied to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-5m57APBqGel4X2vTI7wT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGk4gAAoJEOVv75VaS+3OcmMP/11CeKuY/iP1xpG00GVTDmbc
F2nTabWlYJ3mJ4MFKpxjiapJMMGMXW0o8o7qMhNOlhF7IDYjh8o/+lAdY7BlWnPy
B42TfHD23Zfgv81PDsLijaleferyuhiSbMyV7GtrV9+39oiYowTFLOcOX7IZjF+U
HebDgzJtU2YeEmJd1ijRH/wIC99eoFxxVXJwJY9cqI/XJJosOsjbukqYioZvhJ++
kna52iA1Wu/fEDV8SUyJYcXbdV8KRt+aYIyMnJCjc0a8kKIJJzVb0EWkaNoxrFyG
DRMVHS/lYLJZKmtf+g0tdXj2p7FPaSIxpTzYETEImjVdX5aazR5GGHxeSRXLtI7f
dQ0GiqcWykwWLUJckraTmpbOxhplSYjlqxdI6ARu+kYeo2PfdJzNfYfI8N1FrmG0
QUZbVjFJchhZT63x37pkO69ZG9NjR9MLhACY+nhyHOJEBBTZbHy8KVrDZOVlILJg
XL0PB/yx6CKpxfkTJoeGPlEjhpPy9T5XNt3zma7DRGvEI4kGm6vLUq8q9WFymzB5
UTZWafTDs61kLYe/JjCKNcYlOSEf7SEGhOhvFCS2FX1nCGZTj+6kgk9i2n3csV/G
o+isUcj1bn8KXq0wBXcAY8zI2LTNyWJn1Agl7tLKC5GN15YCXyi9sXkvLtlLptiY
R+21jexWg5bmJfd/kyLu
=b+HL
-----END PGP SIGNATURE-----

--=-5m57APBqGel4X2vTI7wT--
