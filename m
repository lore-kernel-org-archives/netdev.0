From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH 1/1] bug fix: SFP Tx BIAS uses memory wrong
 offset
Date: Sun, 14 Dec 2014 17:48:54 +0000
Message-ID: <1418579334.3599.132.camel@decadent.org.uk>
References: <1413367740-11118-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KcO6hA6Q1+OuyNYqIGEs"
Cc: bwh@kernel.org, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33676 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750701AbaLNRtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 12:49:22 -0500
In-Reply-To: <1413367740-11118-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KcO6hA6Q1+OuyNYqIGEs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-15 at 06:09 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>=20
> SFF-8472 rev 12.0 indicates the SFP BIAS is at offset 100 of page A2
>=20
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks.

Ben.

> ---
>  sfpdiag.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/sfpdiag.c b/sfpdiag.c
> index 812a2fa..a3dbc9b 100644
> --- a/sfpdiag.c
> +++ b/sfpdiag.c
> @@ -48,7 +48,7 @@
>  #define SFF_A2_VCC_HWARN                  12
>  #define SFF_A2_VCC_LWARN                  14
> =20
> -#define SFF_A2_BIAS                       96
> +#define SFF_A2_BIAS                       100
>  #define SFF_A2_BIAS_HALRM                 16
>  #define SFF_A2_BIAS_LALRM                 18
>  #define SFF_A2_BIAS_HWARN                 20

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-KcO6hA6Q1+OuyNYqIGEs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVI3Nh+e/yOyVhhEJAQreTxAA1g/BSM/8xnJN+GkE5GKVAAdx33B4qmHP
GSjE47IkJok/AXpdJfpDBgTp1M0UhaMpBI6GtA4CweTFObRR0weCDBxLSFI3slCj
GTiXUE5WQlQO3o6qZmia+9zjK1BRn5eA3CtowGZUajKdjbY9Dh+1CMHY6TOucg2E
w8Jgsa/CD+X5ZGabqGz47sYZjGXRvcdjJmm9ZH5lxN9dcCWT9IScaCKDn8LVejfB
s1kQ1ZdB8d1IcFEBaQWTjVyN8VwpVIa0DPQujgsVFRLcWnW17gutohHTw0KcNUBO
s2/QjA9zyFBDSZDv59ZeB/fw9sVnshIaBPocnkpG0ibpRoj3+fY8jgMJ/aR4uXyd
AVLXbb/pfdbaMA2kSeQyQjCQyp9uOkgUEKrqTKb00Lfe3y+1IJzViGbnvDR8UVJf
f2c6FgdQd5NUXfgf4j5OE5ABr7c8gGCwKGn6helZWcZsV6agUC5h2E6T/sZnp8K7
j8vO6PG0GRtdlI//ISgnpboFG0yYmaQ5ynATjIuIYMtMbGpfEJVPE4AdZs/ps8jn
OEf/UhQCftzpdU3Zk+tH75HQ7KE+EkLuv9RHuEKdygs41ZSt5yOdnEJlk1WGPH5k
mO0QJb2cELr5hGmzz/XC2c6EWvtnrXXfqBmRfmfAx1MozqzE0iPhEuCe/YZEfuDB
zzT/cUDUJPc=
=sV+q
-----END PGP SIGNATURE-----

--=-KcO6hA6Q1+OuyNYqIGEs--
