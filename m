From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v4] e1000: Support RX-ALL flag.
Date: Thu, 29 Mar 2012 17:56:00 -0700
Message-ID: <1333068960.2622.72.camel@jtkirshe-mobl>
References: <1333061270-4379-1-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pPaxJKFhflyAVfCbkC3j"
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25768 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758448Ab2C3A4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 20:56:02 -0400
In-Reply-To: <1333061270-4379-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pPaxJKFhflyAVfCbkC3j
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-03-29 at 15:47 -0700, greearb@candelatech.com wrote:
>=20
> From: Ben Greear <greearb@candelatech.com>
>=20
> This allows the NIC to receive errored frames (bad FCS, etc)
> and pass them up the stack.  This can be useful when using
> sniffers.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 a680ee6... ab2f748...
> M  drivers/net/ethernet/intel/e1000/e1000_main.c
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   22
> ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)=20

FYI- I was just about to push this upstream :)  Thanks Ben!

This is the same patch Aaron has tested in-house.

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-pPaxJKFhflyAVfCbkC3j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPdQSgAAoJEOVv75VaS+3OMsYP/1rWrNclsyZy9IUwLqYlqwwC
irLIB5zjFPKIdaJcWzKA4X8wGgvXOpmGKFHYopgnSzibx63ZH+zhB3MVepGWB06Z
QY2zRmRrrto0aNY22iGzzI9JKeScNBrMt8qJNIMgxxH5imW6nWp853yfJ4XdKbWc
vZ9eOxeo1frzsbi/89WB2lmxU6tW4n0uK/djWui6f1CekvcQn8cyYv2/hUN8FnXH
2WvaXuncBEk8OW84nDLQZRTWEgFUJIjkUd60ucNz0EF92NCFC75MjZrFe/tbM8MX
EFNSqEx2hAXy0NX2BEBEF0U+0ppj5G8oK+i71W0VIwGCj4ooo2fOheNniCd2+a0H
Rpptli3NI9ypjDkXxqkH4pl2qEs9ecB0ZtDmYQV0HjjD2hNY6S+yFzdJDJyUKYQM
OQrZk0WVRxs6uO2z6AtABpsge3IJBNu1ngfE9w1AJZ2uA3QtjUTBZiytiCpTxVBE
B1tv0TI9hhG+nzLLVNCDFKihyGHYWFgSihecBkHJTQGwPuVAUqW6AEiRLc4UwiRi
oK9gkBeSETQWEAwOFuR12p5RRBGmXgaBW0mrO5XufNnOFF/P1zpZ0JAYxepw+LE0
S04ffR2wJrJEUrp9JOhX7lH11BmCuU1ERKZk1Wpf9WhOsr+tlvwOicKpkwQBNS3l
owJCjAsiy5Z3KIA2jPF9
=ZNTM
-----END PGP SIGNATURE-----

--=-pPaxJKFhflyAVfCbkC3j--
