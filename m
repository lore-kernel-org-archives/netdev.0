From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v4 09/16] e100:  Support RXALL feature flag.
Date: Thu, 16 Feb 2012 16:08:07 -0800
Message-ID: <1329437287.2869.22.camel@jtkirshe-mobl>
References: <1329418421-31574-1-git-send-email-greearb@candelatech.com>
	 <1329418421-31574-2-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KPwwt+CI1RGK0Fn7sI8O"
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:51207 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512Ab2BQAII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 19:08:08 -0500
In-Reply-To: <1329418421-31574-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KPwwt+CI1RGK0Fn7sI8O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-02-16 at 10:53 -0800, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>=20
> This allows the NIC to receive packets with bad FCS
> and other errors.  Good for sniffing packets on flakey
> networks.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
>=20
> v4:  Only flax rx-over-length errors if pkt is beyond
>    maximum expected packet size, not just beyond the MTU.
>    This matches the existing logic for this counter.
>=20
> :100644 100644 6f9f70a... 4d8a616...
> M  drivers/net/ethernet/intel/e100.c
>  drivers/net/ethernet/intel/e100.c |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)=20

Thanks Ben, I will replace the patch that is currently in my queue with
this updated patch.

--=-KPwwt+CI1RGK0Fn7sI8O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPPZpnAAoJEOVv75VaS+3O1EcQAI6w/y0YkYMX/IM2bz1RKOjY
D2hAYhhsEP+8LBq0jl4hppkEikAQIhnx9SfmcZ9892S/tTMun5DEtc2mHcn6EfzW
uTG8XlnWQRPuxGS/wUNGC+6FKdqfzPZiRyQBvjnwKXUPyTpyJKJryzC2NgiKnIEi
36WFOgQaMxx+KhnSnwhh2GL4EJueeGX9i7aSQnvRkTiR5emHcU8rBf8sXxxjLImg
peiz9BB1yhfsGNrYccPDTbkplD6ysTGSHanTjC2GBNI8NhxxG13416bfnP4ksdTt
NVM0HXX2F1p4ANoe2GSRuwM+CKmI2lzl2XwBO+1raw1t3DWEilSUOcNjk+Wv0Mz4
UOYqrwTn6zYRdio2Ne4xmy8hvqlduLQWTmPbmeXGMX9yP326G6DHzgtvCYG0uZN5
YzhL5D/RTyop9G/H5Kyid7urnAkxcIvGZOrJSqnyL1ys87Kmx39tca9k8sHJH6gF
tIO6XWvIzzoeveFb5ZkSx0N/qOrvIaMoWYQ7Fl/sVy1LdmXpuDxI4uHcpnv3pCeh
kcw3jBDSmnShCo+gB/4WWyqCyVUdyMPmCp3hBl66kS50SoNnuZcqzAFiwSq4DpPx
w0so65E6zhkBlBlQpUuDfyH8KN38tkgttxL0imEso0m3ruRUiJ40CMhqyQklxcUZ
nGLIE7oQj7pDaJCkIdNL
=MF6T
-----END PGP SIGNATURE-----

--=-KPwwt+CI1RGK0Fn7sI8O--
