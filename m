From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] fm10k: Add CONFIG_FM10K_VXLAN configuration option
Date: Fri, 03 Oct 2014 15:10:55 -0700
Message-ID: <1412374255.2408.21.camel@jtkirshe-mobl>
References: <1412370352-17680-1-git-send-email-azhou@nicira.com>
	 <542F17B7.80706@intel.com>
	 <20141003.150100.2093419669359736448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jEBVF7qoNRMuCpb7VBTa"
Cc: alexander.h.duyck@intel.com, azhou@nicira.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33732 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757586AbaJCWLC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 18:11:02 -0400
In-Reply-To: <20141003.150100.2093419669359736448.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jEBVF7qoNRMuCpb7VBTa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-10-03 at 15:01 -0700, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Fri, 03 Oct 2014 14:40:07 -0700
>=20
> > On 10/03/2014 02:05 PM, Andy Zhou wrote:
> >> Compiling with CONFIG_FM10K=3Dy and VXLAN=3Dm resulting in linking err=
or:
> >>=20
> >>    drivers/built-in.o: In function `fm10k_open':
> >>    (.text+0x1f9d7a): undefined reference to `vxlan_get_rx_port'
> >>    make: *** [vmlinux] Error 1
> >>=20
> >> The fix follows the same strategy as I40E.
> >>=20
> >> Signed-off-by: Andy Zhou <azhou@nicira.com>
> >> ---
> >>  drivers/net/ethernet/intel/Kconfig              | 11 +++++++++++
> >>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  6 +++---
> >>  2 files changed, 14 insertions(+), 3 deletions(-)
> >=20
> > Looks good to me.  Thanks for resolving this.
> >=20
> > Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
>=20
> I expect this will go via Jeff Kirsher, CC:'d.

Thanks, I will add the patch to my queue.

--=-jEBVF7qoNRMuCpb7VBTa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJULx7vAAoJEOVv75VaS+3OBjIP/0H/eCOxaMRVX3jSIQiqmlKk
OBxBRwYuEa+iocRIPWqt/ycUMMtEGCDZj+4mBQcpPrMB8I0yafIVgKn5nF3oXfMC
yNeLeggTZWkdhg/u4//jhovrnaEopNA8cuGCkOUHrUkIzfSPDbVSsuKs1W0BmqWt
wW+mq8BaxhKZS0hu5595D43v6ON8uUTAhfgHWjselTbCQqa+X4oO9VIQ/lTd7Zj6
2KEQE/RbzoGnjG/sw0CwcjyHJA632zvlQdghujH87ogBdCcBSoAMumr3i3rfxFcV
R2Mm1g+noJpaOwBvUUu1Bc4MSq4QuIdir6MzjLBc2IqxNJ/MoG2OjggidwBoRxaP
6Qn9yjPkNhkHKH/F4iCsSQYNA8A2/DkXdNVF7VY32S39QSwbsM7ah21he0GZ2KwZ
eRjUeaFPafpxFfICKo8imc6MEEdhyHdr2lj83rJRGMkQ4s/sGuJK36na7HHfSxql
JR1pN4yRS+y4S/I2pPLGe0I/Ojk9h+WdQVfYT0NBRMjzcOl08TvB8bsxZosjulT2
oQfsgTk5195wfdTJblGfIHVHqgkBlcwaxBMDUykkhBPvOWo21Lc7VsAldPIlpj3T
w6vszrqutZ38bFC3KMdh7FQYprL2/WUp+IDnFsNInIYWUPvY5pMk07jAJyYQ48PP
EBqwEkfTWKAT71HeJNYj
=IKcm
-----END PGP SIGNATURE-----

--=-jEBVF7qoNRMuCpb7VBTa--
