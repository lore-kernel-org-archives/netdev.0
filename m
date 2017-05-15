From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net] ipv6: sr: fix user space compilation error with old
 glibc
Date: Mon, 15 May 2017 13:01:46 +0200
Message-ID: <14435f10-8eb6-3ad8-7672-d9fc2ef92d08@uclouvain.be>
References: <20170515091828.19349-1-david.lebrun@uclouvain.be>
 <59197D53.8030104@iogearbox.net>
 <fa27cb59-a81e-7f74-7d3f-7feb6d8406f1@uclouvain.be>
 <59198665.7060908@iogearbox.net>
 <d402278a-543f-1cbb-32f9-7d61d8f62f51@uclouvain.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="dTTrcESMVtQAC5qxNUeoUDp9l7HSqwfF8"
Cc: <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:37253 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752926AbdEOLBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 07:01:11 -0400
In-Reply-To: <d402278a-543f-1cbb-32f9-7d61d8f62f51@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--dTTrcESMVtQAC5qxNUeoUDp9l7HSqwfF8
Content-Type: multipart/mixed; boundary="MG2P5OG8kdo4p0PNaFSInFwHUpi9MRiTP"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: netdev@vger.kernel.org
Message-ID: <14435f10-8eb6-3ad8-7672-d9fc2ef92d08@uclouvain.be>
Subject: Re: [PATCH net] ipv6: sr: fix user space compilation error with old
 glibc
References: <20170515091828.19349-1-david.lebrun@uclouvain.be>
 <59197D53.8030104@iogearbox.net>
 <fa27cb59-a81e-7f74-7d3f-7feb6d8406f1@uclouvain.be>
 <59198665.7060908@iogearbox.net>
 <d402278a-543f-1cbb-32f9-7d61d8f62f51@uclouvain.be>
In-Reply-To: <d402278a-543f-1cbb-32f9-7d61d8f62f51@uclouvain.be>

--MG2P5OG8kdo4p0PNaFSInFwHUpi9MRiTP
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/15/2017 12:53 PM, David Lebrun wrote:
> I can fix the issue with a simpler ifdef.

The simpler ifdef works fine, but a patch to iproute2 is still needed.

David


--MG2P5OG8kdo4p0PNaFSInFwHUpi9MRiTP--

--dTTrcESMVtQAC5qxNUeoUDp9l7HSqwfF8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWRmKmgAKCRCNvOfruxno
A9HQAKCJi1qlCfeDqaHGR6wRD2tXxEmnMQCeNgrEjD3T6y1dheILn/THprght50=
=hGPt
-----END PGP SIGNATURE-----

--dTTrcESMVtQAC5qxNUeoUDp9l7HSqwfF8--
