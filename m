From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 19 Aug 2009 09:01:57 +0200
Message-ID: <200908190902.02854.rene.mayrhofer@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <4A7FF66A.1090506@mayrhofer.eu.org> <4A8131DD.7010700@mayrhofer.eu.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3104447.ZcRWYgRCqi";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:53835 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbZHSHCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 03:02:12 -0400
In-Reply-To: <4A8131DD.7010700@mayrhofer.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3104447.ZcRWYgRCqi
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hi everybody,

On Tuesday 11 August 2009 10:54:53 am Rene Mayrhofer wrote:
> Thus, there really seems to be an uncaught case in sky2.c. When
> sky2_phy_power_down is not called, chip should not go down, right? But
> still sky2_poll seems to be called (maybe by an interrupt belonging to
> another network interface but the same chip)?

Is there anything else I could try? We still have this issue, making one ra=
nge=20
of hardware appliances unusable with 2.6 kernels...

best regards,
Rene

--nextPart3104447.ZcRWYgRCqi
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqLo2YACgkQq7SPDcPCS95sJgCfacvz8ZIaU2qY3XadjmVX4cm2
9qgAn2aPwOp/hKaR68phtYBKqRbSRo0O
=AQAq
-----END PGP SIGNATURE-----

--nextPart3104447.ZcRWYgRCqi--
