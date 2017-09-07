From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net 2/2] i40e: Avoid some useless variables and
 initializers in nvm functions
Date: Wed, 06 Sep 2017 18:13:18 -0700
Message-ID: <1504746798.3922.80.camel@intel.com>
References: <cover.1504684488.git.sbrivio@redhat.com>
         <d0881adf53a3f0a546b3e7940b92b4ce938e7e50.1504684488.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-5NzCaqRy8K/1Jjr9AcQS"
Cc: "David S . Miller" <davem@davemloft.net>,
        Anjali Singhai Jain <anjali.singhai@intel.com>
To: Stefano Brivio <sbrivio@redhat.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18454 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752679AbdIGBN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 21:13:27 -0400
In-Reply-To: <d0881adf53a3f0a546b3e7940b92b4ce938e7e50.1504684488.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5NzCaqRy8K/1Jjr9AcQS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-09-06 at 10:11 +0200, Stefano Brivio wrote:
> Fixes: 09f79fd49d94 ("i40e: avoid NVM acquire deadlock during NVM
> update")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_nvm.c | 20 +++++++-------------
>  1 file changed, 7 insertions(+), 13 deletions(-)

This is NOT a fix, it is a coding style preference whether or not you
like multiple returns or a single return in functions.  I do not mind
picking this up for net-next (4.15 kernel), but this does not qualify
for a fix for Dave's net tree.
--=-5NzCaqRy8K/1Jjr9AcQS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmwnS8ACgkQ5W/vlVpL
7c6brBAAnomw2iOL/BCm87+iSRBE2bXBzCbl4XjpoAcYeUKJx6QFDGZBrdF5C2XB
/QbfDvGQNz+y9AnatHbBojgd/fsoiArO5OQu3AQ/rigB0xRiz4Wolp34O7/cGSkz
J+Dba+bX8/0GpT4VNl+HRNM1Ox1DpQCRbz9j57JbF6W84qgM2NaAfj5pQEWvVU9x
Rl+2gNLxrvmpVjCAKQHY+NB7IQUIp7wWqgQwMBrY8AFsNVOfFM8qdOzsKMDWSf8Q
MVjfRS51wDVvFng0khxHpTa//E0yvjLM8dPMq4VcQ4wo2JHRzuUr4XEoAx+qnFm3
pDsNClXJlK0PIQTKgZWLm67mKQhIp1vh6SAOqYc4PyJ66fRYEv9Zr5ORnlhbjG5Z
G1lRbFbx9rLpmxyYKt0Xq6NsZpcXJlTg9MxZb8OFgDehcr4zuJz4dtWFjSldXdbL
UTsXr4r23rXo4s4Js01edd0RFH4vYh7qh2O+IDnUHqH6wsW22B4GcnlUv0AW212e
6NDqvcAPd3QUInL4Vo1c7gcrrX631w/afIuqm3TV/VyFBhe1HVv/rEbjcyInS3HD
EkAxCRH+zmi4hBxFBzKJG5wMmXz4gu0v4h/d8S0hytyrEE8gmrQ6a8H3N2xnCHDF
QpQHG2QwVcrrK8IhfgNALEng9dxSVcwGVPWWkgsVfyQF7M9oJZY=
=4oVl
-----END PGP SIGNATURE-----

--=-5NzCaqRy8K/1Jjr9AcQS--
