From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH 1/1] ssb: remove unncessary out label
Date: Fri, 19 Jun 2015 17:13:11 +0200
Message-ID: <20150619171311.7ed6dfd1@wiggum>
References: <1434704025-20448-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/CI/CQIbjEsYa.7d_GHzTLuF"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pankaj.m@samsung.com
To: Maninder Singh <maninder1.s@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:34092 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866AbbFSPNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 11:13:38 -0400
In-Reply-To: <1434704025-20448-1-git-send-email-maninder1.s@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/CI/CQIbjEsYa.7d_GHzTLuF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 19 Jun 2015 14:23:45 +0530
Maninder Singh <maninder1.s@samsung.com> wrote:

> This patch removes unnecessary label "out" and
> some restructring for using device_create_file directly.
>=20
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> Reviewed-by: Rohit Thapliyal <r.thapliyal@samsung.com>
> ---
>  drivers/ssb/pci.c |    8 +-------
>  1 files changed, 1 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
> index 0f28c08..d6ca4d3 100644
> --- a/drivers/ssb/pci.c
> +++ b/drivers/ssb/pci.c
> @@ -1173,17 +1173,11 @@ void ssb_pci_exit(struct ssb_bus *bus)
>  int ssb_pci_init(struct ssb_bus *bus)
>  {
>  	struct pci_dev *pdev;
> -	int err;
> =20
>  	if (bus->bustype !=3D SSB_BUSTYPE_PCI)
>  		return 0;
> =20
>  	pdev =3D bus->host_pci;
>  	mutex_init(&bus->sprom_mutex);
> -	err =3D device_create_file(&pdev->dev, &dev_attr_ssb_sprom);
> -	if (err)
> -		goto out;
> -
> -out:
> -	return err;
> +	return device_create_file(&pdev->dev, &dev_attr_ssb_sprom);
>  }


I don't really think this change adds any value, but if you insist on
it you get my acked-by.


--=20
Michael

--Sig_/CI/CQIbjEsYa.7d_GHzTLuF
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVhDGKAAoJEPUyvh2QjYsOnz4P/1YYsopGsUY+tEgWnwDwOrW9
bZv4iWQiSMA7uMy7uzWiaRy0SNQrLRItYiuZzah/asOdSE/Sb7lFJdt7qfdeTdyj
DyjY3kiUMXhZSYYtmYU9cpoMF9PpWyDAL/BvAaSpi8B9LGeBtUpfWZamT2D1VEjI
jIQwo+/HQvE3RP5dZCvRcG5ixLrIrdCy/a2IV8RSl95gT8kR7t98d1KM10Y8R/qh
/70FRfhyF6sY6iVdpNDkUjrs1Dui7Hc72I0jZf65ZMSkSBH84nihn+T9isYOAFC3
NaPhvJwwzeGu3L1GL6ZA9bK/tgEb/pcC1WQTZUnirslc2NzK7gEPE/VKxW+8yNF0
7VsyvNaRvH3IbnxctpAjmSMeUIHsIR0JRkfjlcNaYtrk42uzRFyJRzTo+KfDkUz4
d/PTEzS2y2kJ3hH6kdILffWsmkoLhYAL9ogds5qqBckTDqi5keFwZWmWhgSyG0oV
tzeiLdVKA9ye6iXOk/+8ewDa3QEb8R+od2wcdtg6Eaq7G7RV7fa5Wty+Sy6wxCWM
Nqj1U/sXVrTmWXM/V20jwDq40eI23iY/Zzr6yyBYNHlqudp3VFvnZvw2lfoy7lSJ
zTVCy2jzwkV9NeFFq1GwQianmpb1/kQXvGTPW8EKtUwGxvskDdZjJOxNXDRUZStG
tNZEIOZtNFUV/BeBBjtr
=vO39
-----END PGP SIGNATURE-----

--Sig_/CI/CQIbjEsYa.7d_GHzTLuF--
