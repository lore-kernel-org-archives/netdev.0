From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next ] i40evf: Rename i40e_ptype_lookup
 i40evf_ptype_lookup
Date: Sat, 15 Mar 2014 00:36:44 -0700
Message-ID: <1394869004.2167.124.camel@jtkirshe-mobl>
References: <87k3bw2xjp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-H43CN285Y2k80H7jKCl2"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Kavindya Deegala <kavindya.s.deegala@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51224 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402AbaCOHgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Mar 2014 03:36:45 -0400
In-Reply-To: <87k3bw2xjp.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-H43CN285Y2k80H7jKCl2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 16:03 -0700, Eric W. Biederman wrote:
> When compiling the i40e and the i40evf driver into the same kernel I
> get:
> LD      drivers/net/ethernet/intel/built-in.o
> drivers/net/ethernet/intel/i40evf/built-in.o:(.data+0x300): multiple
> definition of `i40e_ptype_lookup'
> drivers/net/ethernet/intel/i40e/built-in.o:(.data+0x780): first
> defined here
> make[3]: *** [drivers/net/ethernet/intel/built-in.o] Error 1
> make[2]: *** [drivers/net/ethernet/intel] Error 2
> make[1]: *** [drivers/net/ethernet/] Error 2
> make: *** [sub-make] Error 2
>=20
> Fix this by renaming the i40evf version of this structure from
> i40e_ptype_lookup to i40evf_ptype_lookup.
>=20
> This build failure was introduced in:
> commit 206812b5fccb808d1194344eaa942f68f59b2630
> Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date:   Wed Feb 12 01:45:33 2014 +0000
>=20
>     i40e/i40evf: i40e implementation for skb_set_hash
>=20
>     Original comment from Tom Herbert <therbert@google.com>
>=20
>        Drivers should call skb_set_hash to set the hash and its type
>        in an skbuff.
>=20
>     This patch builds upon Tom's original implementation and adds
>     the L4 type return when we know it is an L4 hash.
>     This requires use of the ptype decoder ring, so enable it.
>=20
>     Change-ID: I2f9fa86d1a6add58cff13386f7f4238b1abcc468
>     CC: Tom Herbert <therbert@google.com>
>     Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>     Acked-by: Shannon Nelson <shannon.nelson@intel.com>
>     Acked-by: Mitch Williams <mitch.a.williams@intel.com>
>     Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
>     Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Catherine Sullivan <catherine.sullivan@intel.com>
> Cc: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/intel/i40evf/i40e_common.c    |    8 ++++----
>  drivers/net/ethernet/intel/i40evf/i40e_prototype.h |    4 ++--
>  2 files changed, 6 insertions(+), 6 deletions(-)

Correction, I guess I did not already have a fix for this in my queue,
so I have added this patch to my queue.  Thanks Eric!

--=-H43CN285Y2k80H7jKCl2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTJAMMAAoJEOVv75VaS+3Oet4P/0ktVMh6jXbFjBYonnr8ftC2
2vpPdTILoBEvKXHOWFkbrBpZyAnT/yB8i9UPOSPeSY7LSmtoE1bZ4BBHa4Tlt8dd
jbcgR4ZpbZWr01zLgnyAvxVkO6bkOhGg77+RXNouedcn1Hbcekfv01zoIVuFQMZ0
6MKmz78nA+yuwJffgSlmhTerXAosj996XTiO6aLO9euAox3wtW7Hfg0eokTdliGs
T10BCsnywHzbUaNRFqkUo5KW2zq9XuuvwHn5R/sgUn1q+8hSUtA6PQOkDrfQCa1F
Ut+VkV8T1cUt5DUHmF59rqBxeNTGyHNpULF5mRaKAnTu+dNAqlykWuPVaaVnzk4Z
gyogsVrHKLy8ZXHkGiwJz522SgkC+fOpQMoa8+QBMqWNrnQLYrEPasdWU4MatjhW
9bd4vgp2emIqyb6aNZLCyNKP8w53fAbwXmrjkBWtfYsT3PJmtRQPv1IK0P71ljaz
CZUNEEA9G0dFTibJZ1SVuUnQAEE/c2VT5JJvWnxR/kSSTCWPMarvyU/ES/iGEanR
csYE38r1BNwyPuB3lnSMENX18bEOZIOMvgOURhpWskop6bWDn5ZLR7a6bHzEmO36
E6cYUSTm7caxudmpDavx2C+3f/dZ1gpMYVdrbOgju+mOe/E+0B31qMpSN5oNcB78
W16BKfPzxlYuRsI1uQug
=3yqy
-----END PGP SIGNATURE-----

--=-H43CN285Y2k80H7jKCl2--
