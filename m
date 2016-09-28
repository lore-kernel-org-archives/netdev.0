From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/5][pull request] 1GbE Intel Wired LAN Driver
 Updates 2016-09-22
Date: Tue, 27 Sep 2016 18:50:16 -0700
Message-ID: <1475027416.6522.35.camel@intel.com>
References: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-bEmJuvbPJPra4ffM9zn8"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        bhelgaas@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:14689 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933579AbcI1BuS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 21:50:18 -0400
In-Reply-To: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bEmJuvbPJPra4ffM9zn8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-09-22 at 23:38 -0700, Jeff Kirsher wrote:
> This series contains updates to igb, igbvf and PCI quirks.
>=20
> Wei Yongjun makes a function static to shut up sparse.
>=20
> Todd bumps the igb and igbvf version, which is long overdue.
>=20
> Jake fixes an issue where the PPS SYS_WRAP interrupt was not re-enabled
> after a reset, which resulted in disabling of the PPS signaling.
>=20
> Sasha adds a quirk for 82579 devices, which was reported by Red Hat.
> The issue is that 82579 has a problem reattaching itself after being
> detached, so disable the FLR capability in PCIe configuration space.

Based on feedback, I will drop patch 5 in the series and re-submit the
series, while Alex and Sasha re-work the PCI quirk patch.
--=-bEmJuvbPJPra4ffM9zn8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJX6yHYAAoJEOVv75VaS+3OSGgP/iDZmPGEs4ruFVdjpCt+/rIj
9YwVYHXAcJxrlnNvNsGjOiDpBe7bDn/wvK17lFjgmS0+yXbucYhdHaK/w3KCVrk1
xTA/DcMdg1UncPupjCNU4CCLMrwN4LCP18qbfubTGjHg/zc1f3+q61Q4f5QTdhxJ
AT63I2phxdkcunZQU7bXOVJ5j4fz/9D44D5kAYiemNvVq8NfIQRZ0EdU2MUDhLOu
lCyEM1gBx8yJSF9oULLoqeCJiBJWpqF0qrtm1KihVGjp20g+gmaqF2h2ZjLsqSQI
qYxTeMKH3/egCMpsm7KdwKxo0kP2qDwNeLJ5rqhQ66bfOZD+X3sSWSl729e3Q9/X
kqhpq6j5sxaqz+c/tZYwFNDCjXsq9d2ocZ7oqcPALD3eSiqwSavePqpw22lq4dB8
PdfGPZ43Js0uOb7U6/YmpGFRB2KNSS0yDMZyA67AiZ9tN5VBiVtV+ErTO3C5Ei1H
FQaLKGSaAa9FQzcO8L6M4CKmQXeImhYWHHfaZtV99v2Vwn2rdjsvmJextSuWYITV
kpVxdhGNpEMjAXW78d8n2oSiAx9WWAaB7uwYkgidpO8wJ1i7CjnpPRnWDoPNOsrb
lzk5uIxwDJOYMKLbnVfFTQZw4SXNHmaaOFnFmI/HYgp9wzI69YU3x6vE57/Ry+Mm
uWQpcAa/7CGSfIEO2108
=CN9l
-----END PGP SIGNATURE-----

--=-bEmJuvbPJPra4ffM9zn8--
