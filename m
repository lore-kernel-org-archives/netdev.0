From: Michael Pyne <michael.pyne@kdemail.net>
Subject: Re: [patch 2/8] forcedeth: fix MAC address detection on network card (regression in 2.6.23)
Date: Wed, 21 Nov 2007 18:50:31 -0500
Message-ID: <200711211850.36744.michael.pyne@kdemail.net>
References: <200711212302.lALN2sF8013655@imap1.linux-foundation.org> <F72FA20C31DD4F4C997B91C5B3690A091A9857@hqemmail07.nvidia.com> <20071121154723.34c5f647.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1785084.xTenOpkFBb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Ayaz Abdulla" <AAbdulla@nvidia.com>, jeff@garzik.org,
	netdev@vger.kernel.org, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:48655 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283AbXKUX45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:56:57 -0500
Received: from postalmail-a4.g.dreamhost.com (sd-green-bigip-202.dreamhost.com [208.97.132.202])
	by hapkido.dreamhost.com (Postfix) with ESMTP id AFFDA178CF3
	for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 15:56:56 -0800 (PST)
In-Reply-To: <20071121154723.34c5f647.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1785084.xTenOpkFBb
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 21 November 2007, Andrew Morton wrote:
> On Wed, 21 Nov 2007 15:34:52 -0800
>
> "Ayaz Abdulla" <AAbdulla@nvidia.com> wrote:
> > The solution is to get the OEM to update their BIOS (instead of
> > integrating this patch) since the MCP61 specs indicate that the MAC
> > Address should be in correct order from BIOS.
> >
> > By changing the feature DEV_HAS_CORRECT_MACADDR to all MCP61 boards, it
> > could cause it to break on other OEM systems who have implemented it
> > correctly.
>
> Getting an OEM to fix their BIOS isn't always a simple thing...
>
> Perhaps Michael's change should be enabled by a module parameter for
> those who happen to have the busted BIOS?

I have contacted the motherboard vendor about this a couple of weeks ago pe=
r=20
Ayaz's request and have received no response.  I've also upgraded to the=20
latest firmware for this motherboard and the bug remains.

I think it would be ideal if there were a way to detect broken MCP61's (i.e=
=2E=20
those with a Gigabyte MAC ID instead of the nVidia one) and only reverse th=
e=20
MAC address then.  A module parameter would also work but then I'd need to=
=20
remember to apply it. :)

Regards,
 - Michael Pyne

--nextPart1785084.xTenOpkFBb
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBHRMRIqjQYp5Omm0oRArdhAKDfQpGcO4OxVQRsrNEKOY+PitAaXQCgulCD
hsKOB3B1Xa7jluq5aWyNzpc=
=vNA/
-----END PGP SIGNATURE-----

--nextPart1785084.xTenOpkFBb--
