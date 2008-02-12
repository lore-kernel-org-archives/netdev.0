From: Prakash Punnoor <prakash@punnoor.de>
Subject: Re: E1000 (PCI-E) doesn't work on nforce430, MSI issue.
Date: Tue, 12 Feb 2008 22:34:42 +0100
Message-ID: <200802122234.47164.prakash@punnoor.de>
References: <m37ih9ooim.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart18226953.dDsoI1WA4D";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-12.arcor-online.net ([151.189.21.52]:51425 "EHLO
	mail-in-12.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751089AbYBLVew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 16:34:52 -0500
In-Reply-To: <m37ih9ooim.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart18226953.dDsoI1WA4D
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On the day of Tuesday 12 February 2008 Krzysztof Halasa hast written:
> Hi,
>
> Is it a known problem?
> Linux 2.6.24.2, ASUS M2NPV-MX mobo, nforce 430 based, two PCI-E x1
> E1000 cards, 32-bit kernel, default e1000 driver (PCI IDs disabled in
> e1000e).
>
> Don't work by default. "pci=3Dnomsi" fixes the problem.

Probably the patch to enable msi bit on the host bridge(?) is still missing=
 in=20
mainline. I needed that patch to make msi work on my MCP51 system.

=2D-=20
(=B0=3D                 =3D=B0)
//\ Prakash Punnoor /\\
V_/                 \_V

--nextPart18226953.dDsoI1WA4D
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iD8DBQBHshD3xU2n/+9+t5gRAmRZAKD529mjcVX0vsE4FJqtbK6AFYBIrACfee4C
P4rW89oQjEQ6tibXqco6UB8=
=cJ8I
-----END PGP SIGNATURE-----

--nextPart18226953.dDsoI1WA4D--
