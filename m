From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 01/24 for-2.6.25] DM9000: Fix endian-ness of data accesses. Patch from: Laurent Pinchart <laurentp@cse-semaphore.com>
Date: Thu, 7 Feb 2008 14:28:38 +0100
Message-ID: <200802071428.38849.laurentp@cse-semaphore.com>
References: <20080205000159.432081941@fluff.org.uk> <20080205000814.539308209@fluff.org.uk> <47A99E1A.3050808@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1414390.0q1aJvsAsz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, daniel@caiaq.de
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:29417 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753956AbYBGN2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 08:28:01 -0500
In-Reply-To: <47A99E1A.3050808@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1414390.0q1aJvsAsz
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 06 February 2008 12:46, Jeff Garzik wrote:
> two comments:
>
> 1) you should be using __le16 type
>
> 2) seems like you should do the same for RxStatus, rather than splitting =
it

The DM9000 datasheet (or rather the application notes) describes two distin=
ct=20
fields, even though they both contain some kind of status information.

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chauss=E9e de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1414390.0q1aJvsAsz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBHqweG8y9gWxC9vpcRAkqjAJ9BbTd1649Vv5O55vrXNMEnzbZnMACgjbWX
KR8u39NQJAhu66LKZp7Q8V0=
=stJW
-----END PGP SIGNATURE-----

--nextPart1414390.0q1aJvsAsz--
