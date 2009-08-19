From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 19 Aug 2009 17:11:23 +0200
Message-ID: <200908191711.24085.rene.mayrhofer@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <200908190902.02854.rene.mayrhofer@gibraltar.at> <392fb48f0908190800j508456d6h9c520e82bc7f51e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4676411.Yhhk7fr241";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:56012 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbZHSPLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 11:11:32 -0400
In-Reply-To: <392fb48f0908190800j508456d6h9c520e82bc7f51e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart4676411.Yhhk7fr241
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable

Hi Mike,

On Wednesday 19 August 2009 05:00:31 pm Mike McCormack wrote:
> There's a couple of things to try:
>
> * try the latest sky2 code from net-next-2.6
> * try adding an msleep(1) after sky2_rx_stop() in sky2_down()
> * try adding a check for rx_ring and tx_ring being NULL in
> sky2_status_intr(), and disable napi while freeing the buffers in
> sky2_down()
>
> I've got an untested, ad-hoc patch against net-next-2.6 for the last
> two bits ...

I will try all these (hopefully in the next 24h), starting with the patch y=
ou=20
sent me in PM, then the patch attached to this email, and finally pulling=20
sky2.c from net-next-2.6 and applying this patch.=20

best regards,
Rene

=2D-=20
=2D------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/

--nextPart4676411.Yhhk7fr241
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqMFhwACgkQq7SPDcPCS95x0gCfaBY4NcAB+g00akibjjR8o1pn
sv4AoM+it/MxemQmDIajwl6bMw2BPUFi
=FOU+
-----END PGP SIGNATURE-----

--nextPart4676411.Yhhk7fr241--
