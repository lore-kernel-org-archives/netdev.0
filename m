From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000e: Avoid wrong check on TX hang
Date: Wed, 21 Mar 2012 22:11:09 -0700
Message-ID: <1332393069.2906.135.camel@jtkirshe-mobl>
References: <OF66508452.5C6F589E-ONC12579C8.005ECBB5-C12579C8.005F4640@transmode.se>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kbPSDAkz8uL32GsfkEtw"
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34510 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626Ab2CVFLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2012 01:11:11 -0400
In-Reply-To: <OF66508452.5C6F589E-ONC12579C8.005ECBB5-C12579C8.005F4640@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kbPSDAkz8uL32GsfkEtw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-03-21 at 18:20 +0100, Joakim Tjernlund wrote:
> I think commit 09357b00255c233705b1cf6d76a8d147340545b8(e1000e: Avoid wro=
ng check on TX hang)
> needs to be applied in 3.2.x (and 3.0.x) too.
>=20
> We have seen this on routers(we got 3):
> e1000e 0000:11:00.0: eth9: Detected Hardware Unit Hang:
>   TDH                  <a4>
>   TDT                  <a7>
>   next_to_use          <a7>
>   next_to_clean        <a4>
> buffer_info[next_to_clean]:
>   time_stamp           <1008e849f>
>   next_to_watch        <a4>
>   jiffies              <1008e85d8>
>   next_to_watch.status <0>
> MAC Status             <80387>
> PHY Status             <792d>
> PHY 1000BASE-T Status  <3800>
> PHY Extended Status    <3000>
> PCI Status             <10>
>=20
> Applying the above patch on 3.2.12 makes the error go away.
>=20
>    Jocke
>=20

Thanks Joakim, I am aware of the issue/fix.  I will submit the fix to
all stable tree's back to 2.6.32.  Look for me posting the patch this
weekend.

--=-kbPSDAkz8uL32GsfkEtw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJParRtAAoJEOVv75VaS+3OI+4P/3num0i/FukLDeqXw+1Jyios
+JthSlE+SBhERFLFjzRuO+6bSeok7WjifPAVajAwvUi8y4Bh0ePS6dVhPOqQkt5c
/w/QjSvwiwk4HR/OUlfftKVFqITRht8lFNT64a/lF6AGEygTjPYDk0XoHN8r8rNV
GjeRqdNQsVGX1UCtBJMlNrivSZIlTI//xjaTRJK6CKYYFmdy/ArTjaz7Z6gLFNg/
b3yhUirWbEgGBOZ34Hi0E7AK1P26P5OxTF1GyDcdjcThEvuLlW7ZtrBRBfmUDysK
DqCvD+yu9+lTrhCCECv+IMzJuIfKh3ZXdk48DwwoDR5+Pys7AAGs9FUy99qyXO8O
nsua0a0wno3trD38kpZFr7NI+TMXkUNk9Ar9eOG7cvuLMHi2swkYeHbk36UBu16x
L8ZfIYPR+J5+Q4S5xniwSpy42hWoQZGxE3v7BxLZHdiFShBzfUyDm1Xzix+uT3JJ
Hp7iMmjNPAfr8MV7wXFIE87KeQwM37EP/DrqLjE1ducPxXFP/KyE2aS/Sf2Vel3Y
Dd+2IdNd747JBSDT1WBhF3OjZ8AChowjlVoM+A1J4yah7r3km8PJaX1TfizQ30dW
pV0yAu/ySaTXfgg2HIVnl3RYh6GlwAK4/Ioog9qHRk6S0i5AZp42xl/ZCPKFw06d
/0Bk0UVcgPwLhCC/5uKf
=pwKz
-----END PGP SIGNATURE-----

--=-kbPSDAkz8uL32GsfkEtw--
