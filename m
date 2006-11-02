From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather thand80211-specific
	qdisc
Date: Thu, 02 Nov 2006 23:56:36 +0100
Message-ID: <1162508196.3381.0.camel@johannes.berg>
References: <C86180A8C204554D8A3323D8F6B0A29F018B5DE3@dhost002-46.dex002.intermedia.net>
	 <1162485837.16971.5.camel@johannes.berg>
	 <20061102143421.1f6c8ba3@freekitty>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DQq6cEyVRxzOkNI84uUx"
Cc: Simon Barber <simon@devicescape.com>,
	Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:2995 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752437AbWKBW7d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 17:59:33 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061102143421.1f6c8ba3@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DQq6cEyVRxzOkNI84uUx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-11-02 at 14:34 -0800, Stephen Hemminger wrote:

> It makes 802.11 packet capture easier as well.  Please don't invent yet
> another network access object for the master device.

Oh, but the master device doesn't get any packets you could capture. For
that, you need to add a monitor interface.

johannes

--=-DQq6cEyVRxzOkNI84uUx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUp3o6Vg1VMiehFYAQKNPxAAq74LqiOoCkSpCmwmty7fWiqEBWhHssaZ
4Gx1zrA4VhNyyLF5x1/E9b/JEc5zXdw/DpdCJQwbXtO7dLGsl66rFx/748ji0srE
3+uyuyVPiT1TmcaNYUK8msjHhCk4f7UeNtm0kV1sK/LkmqALIqQTdKibEYlN/pCj
41x9nlfzYH9bbwV88WVoaM7+OahjacTrBFQccrP9Blsol45c/I9vk3zAyJhrkbiL
7BBzLPlGchYFI2w2SdKb2270fbqdrOuU4+NiMjKkInFuMSwwB5roK94Eb6rBykKj
DnsCcBpZ6E72ikolTEpR+tNLwsixEWb3N+d+A6R5Q2yTftzQyvNAGrN8oeD8n9fL
6l9GxArRmmvPQwJfiQ7UdPhiUbXY/4oCdKm5LDsA6QWNqYnb+eG1uyhufv2324AB
o0yfqExEtxGsfiWsBGHTbZoeqH9+8m4u76njyHLZ2b+XZMh4kqe4+ZZu9fOejGP5
RF2cnAej7tJvQb1jj574//gLEjWofpbY/5bOeBuqJABkjSqfy/INTRd2Dgfi63YX
mIUI6fNiydsZ9IVWzkWRCTQ4PQyQesGlgiZ7C4qeQhbcFjhYEb4o3Rds8dyOt3gE
tgewvCd0YNf2cCoGNiCsSXQCJFwYOJGKkZaF+jKiCNqZrd8cnpT1vccu9yLfJYZn
oe43jPxO77M=
=mgg3
-----END PGP SIGNATURE-----

--=-DQq6cEyVRxzOkNI84uUx--

