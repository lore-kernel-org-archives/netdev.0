From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: enable VLAN stripping for VMs with i350
Date: Wed, 11 Dec 2013 06:05:49 -0800
Message-ID: <1386770749.2204.17.camel@jtkirshe-mobl>
References: <1386754354-22039-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wdrQ3i6NjKahmc+tRpiq"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	e1000-devel@lists.sourceforge.net, carolyn.wyborny@intel.com
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57907 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380Ab3LKOG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 09:06:26 -0500
In-Reply-To: <1386754354-22039-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wdrQ3i6NjKahmc+tRpiq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-12-11 at 10:32 +0100, Stefan Assmann wrote:
> For i350 VLAN stripping for VMs is not enabled in the VMOLR register
> but in
> the DVMOLR register. Making the changes accordingly. It's not
> necessary to
> unset the E1000_VMOLR_STRVLAN bit on i350 as the hardware will simply
> ignore
> it.
>=20
> Without this change if a VLAN is configured for a VF assigned to a
> guest
> via (i.e.)
> ip link set p1p1 vf 0 vlan 10
> the VLAN tag will not be stripped from packets going into the VM.
> Which they
> should be because the VM itself is not aware of the VLAN at all.
>=20
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.h | 4 ++++
>  drivers/net/ethernet/intel/igb/e1000_regs.h  | 1 +
>  drivers/net/ethernet/intel/igb/igb_main.c    | 7 +++++++
>  3 files changed, 12 insertions(+)

Thanks Stefan, I have added this patch to my queue.

--=-wdrQ3i6NjKahmc+tRpiq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSqHE9AAoJEOVv75VaS+3OyOoP/i+fLgpDJxfnQkcl4IH6Choh
JJJD8RZpMigPJz7e7DK3B+N2ppc6Tp8sreG8sH8Nii8mqUmCWQ1fTgA79gQelBzq
H5xsCxP6dTmb1U1G3sxRKUSWi83seykWmr2NOYVXHad6NjWkKk6xyHo59eVl2ube
/Nhe8fie3qb0NJBLu9IhqRAQxBdetAuYotyYWB5EwuWpRMOXDDWfMK8d0Ry2COE6
LzNkBUOMIcioJvBIBtuh43QLAYo+MmojLcZfLJpupCxHUBTRAEwopkKyz0g4cqpT
go2yI5SB7kzwxbn0jtj3IcfTA8MgIVeRjI8NRMD7AuHsdHE//4uKDoF3W2o3iz4k
GGAqKLfmJkdBkjUpeK1yEMxMtCR0Rzy3gfIl3Tm9yUnvbgr6aNyVI0d7GB6MDBcg
S+HhdP0cZIyweqe3rVAF0c16hWj5l8C1YL2NC3TxFBONs6q9ToA88+2w4aybaTQo
a5iV1xLj4QC45iK6UCoq5T+QSvBWv068CLrGXwvz9sC0WBq9kVR6OKwLFzVIbdQq
uPoZ9H5BzZ91m9tels9QdZ+Vxx6qSKCFFm7fnMRu1rYakNgXGfv7T5i/Tv4ED1Ke
FKwOLN+SIYqFk9a1Aew7AKEJB/1nr6vxORT761pTKQea6oZ2+7T0PSsf0w6gKDm/
Ocvc84Ga3SPVCoMweJpu
=iu33
-----END PGP SIGNATURE-----

--=-wdrQ3i6NjKahmc+tRpiq--
