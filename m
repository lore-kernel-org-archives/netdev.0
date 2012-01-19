From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] e1000: add dropped DMA receive enable back in
 for WoL
Date: Thu, 19 Jan 2012 01:42:42 -0800
Message-ID: <1326966162.2410.55.camel@jtkirshe-mobl>
References: <20120118154633.10215.19965.email-sent-by-dnelson@aqua>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-q3u8oP9fBD7XZoct3jn/"
Cc: netdev@vger.kernel.org, Tobias Klausmann <klausman@schwarzvogel.de>
To: Dean Nelson <dnelson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37591 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755929Ab2ASJmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 04:42:45 -0500
In-Reply-To: <20120118154633.10215.19965.email-sent-by-dnelson@aqua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-q3u8oP9fBD7XZoct3jn/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-01-18 at 10:46 -0500, Dean Nelson wrote:
> Commit d5bc77a223b0e9b9dfb002048d2b34a79e7d0b48 broke Wake-on-LAN by
> inadvertently dropping the enabling of DMA receives.
>=20
> Restore the enabling of DMA receives for WoL.
>=20
> Reported-by: Tobias Klausmann <klausman@schwarzvogel.de>
> Signed-off-by: Dean Nelson <dnelson@redhat.com>
> Tested-by: Tobias Klausmann <klausman@schwarzvogel.de>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)=20

Thanks, I have added the patch to my queue.

--=-q3u8oP9fBD7XZoct3jn/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPF+WSAAoJEOVv75VaS+3OSGIP/i0K/9RTohry5BAAM2rlhSlR
YOHZYXBgydfrjRNa9S1X7l1fGRxgtEXagix7nSFHB8WjFqDj4YkSUm1dC6bA6RMB
BIclGegnhUrOWa1/v8TN4H7k3ftNKWe4s4hW54Bb7BxTN9dDDXsfEuvj8yOSiIaN
9TXUZ/xiBmfqoc5cCglslnv80l22TrCn5BdrRJzT1R9kFKUnUIMkFwetwynKBw30
ll0saLBSfU2K/Z2DMA3abZaXfQbMb+41D1CMPkr7R3p6+i90/HSvKAxAqSf/JR6j
8iJHwDKAWUXRZsx+W+ftzcSZfl8a+sl9m1hPqd+CockHh7omWZsS9sKW6lW+XR1J
E/4oqcax4i3WaUGFG0+cAUukuWmFT0TwwutmkZIW/x5IVkHs9a5p8D+lVOopVy85
cCQltOdvSTu9jumHemD5ACPT/sUn/F5lUt+EaDVuY/jjeSQqR8Nok7NTiOxJ2SdF
3hzj/yRQNsfBs/LZtxLs8VMAJJGGzpmeR1ijUf3Dh+XhplmII21cxjGsp6PsU1Gv
dDPaK/zQUcSPzNB0/pKMmjdX50jPS8x49cONazoxXN0ffIyuGvCKCJHSqaCZ8b4N
f4M/ciohquawBicYRKmzefwqZQrijYZ1ygAeGcGSri8HhaH9zim5agJNJC1FUAI8
xaBvamNIQ9qBoou2hUOa
=+T6s
-----END PGP SIGNATURE-----

--=-q3u8oP9fBD7XZoct3jn/--
