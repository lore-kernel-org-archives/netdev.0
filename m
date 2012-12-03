From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH net-next 0/2] igb: fixes and improvements for irq fallback
Date: Mon, 03 Dec 2012 11:51:09 -0800
Message-ID: <50BD02AD.4060605@gmail.com>
References: <1354540501-18407-1-git-send-email-sassmann@kpanic.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig7EC617D1DC821FC4DD0B0193"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	alexander.h.duyck@intel.com, carolyn.wyborny@intel.com,
	jeffrey.t.kirsher@intel.com
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:4304 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116Ab2LCTvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 14:51:11 -0500
In-Reply-To: <1354540501-18407-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7EC617D1DC821FC4DD0B0193
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/03/2012 05:14 AM, Stefan Assmann wrote:
> The interrupt fallback code should utilize the same code that's used fo=
r normal
> setup instead of duplicating it. It also has some shortcomings when it =
comes
> to situations where for some reason request_irq() fails to allocate vec=
tors for
> MSI-X. Hoping to address these with this patchset.
>
> Would be nice for these patches to go through Intel testing before incl=
usion.
>
> Stefan Assmann (2):
>   igb: remove duplicate code for fallback interrupt initialization
>   igb: release already assigned MSI-X interrupts if setup fails
>
Thanks Stefan, I have added the patches to my queue.


--------------enig7EC617D1DC821FC4DD0B0193
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJQvQKtAAoJEOVv75VaS+3OtjkQAImevn13QRANMftgqb10XYA8
UNR0yW0r0zHs3OlVR1Rq440vBSlw6zSWiYoxeIVB65/ckAoFPY3mIrB+72v+cdpR
UPwwpeIiM4UknIoQz9y2yTH7VofjuqPN2AMWfDGbItVeoF2/JHdCEwtJnsmdwep0
Q1EyqNcyA+Ssy4cyAj5fD/nOoJBRnKVzQRxjq03oe1FxtK5Z8Jlg2p40+zP6n3p1
Ljas8pO7Cr96fpWfasqJ2CheS8d5q/RF+6MmY1Fdjc/eFs6O4C0Y0YL5VeAyzjQE
fF5q2HEn49AIMEsjOcflKo11ZeyW5wCZ2Sp6X6ctakeRD1fY3LK5R5LQ7eJK3WES
fKW14PTfAlVYHMPZKsCUIiEQk4I6vyD6/oa0XZV/v897zaBUpnNq254f38J1G/vO
6FU0RXy0of38hhuCwWZ5jlQR2uLrVm71X593pNm9HAOIIgwjtERLCQqYnQS9sc9e
N+I2km+KEKiSf961A11ZFRVsFQ1xpHls8dPXfdYQo73n5FkO+v0qpAujemPGITr6
7X83BKw2N8JqL3qa77NEj9uedOzx/XTCyT9RV8K7CILEGSptx5Jyr+WH/MOqHVoA
6y1NHPg+6CdBsAGod7ofPQ8867mvqcQDLQ4CH8hB/9uJE0WXqhsNJLQVLqYkUvHm
ukH82o3L2unaYBdVWweX
=kmkW
-----END PGP SIGNATURE-----

--------------enig7EC617D1DC821FC4DD0B0193--
