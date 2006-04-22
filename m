From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH TESTING] bcm43xx PIO mode
Date: Sat, 22 Apr 2006 22:07:05 +0200
Message-ID: <200604222207.05840.mb@bu3sch.de>
References: <200604221718.54245.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart88138024.uu3YB66WZJ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:32155
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751114AbWDVUC5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Apr 2006 16:02:57 -0400
To: bcm43xx-dev@lists.berlios.de
In-Reply-To: <200604221718.54245.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart88138024.uu3YB66WZJ
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 22 April 2006 17:18, you wrote:
>  	bcm43xx_lock_mmio(bcm, flags);
> +
> +	txctl =3D bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
> +	if (txctl & BCM43xx_PIO_TXCTL_SUSPEND)
> +		return;

Ah, and yes, I see the bug here. :)
But that normally does not trigger anyway. So no problem
for testing.

And I forgot to say that PIO mode is enabled by module
parameter pio=3D1

=2D-=20
Greetings Michael.

--nextPart88138024.uu3YB66WZJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBESozplb09HEdWDKgRAr9gAJ40evaZzqxfLGSFPz71Qdqj7rIdAwCgvNmp
Wsfh0LAWRC/oteMOde0ea7o=
=Hv9l
-----END PGP SIGNATURE-----

--nextPart88138024.uu3YB66WZJ--
