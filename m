From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 4/6] d80211: add a struct device* hardware property
Date: Fri, 3 Nov 2006 17:27:35 -0500
Message-ID: <200611031727.41131.flamingice@sourmilk.net>
References: <20061102223854.692274000@sipsolutions.net> <20061102223854.692274000@sipsolutions.net>> <20061102230015.555750000@sipsolutions.net>>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1806038.m4kecpxOFe";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:44184 "EHLO
	annwn13.rutgers.edu") by vger.kernel.org with ESMTP id S932205AbWKCW2A
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 17:28:00 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20061102230015.555750000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1806038.m4kecpxOFe
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 02 November 2006 17:38, Johannes Berg wrote:
> +	/* hardware device */
> +	struct device *dev;
> +
Can we just pass this in as an argument instead? No one is gonna look at it=
=20
ever again after ieee80211_register_hw, so I don't think it's worth putting=
=20
in struct ieee80211_hw.

> +	local->mdev->class_dev.dev =3D hw->dev;
Why not use SET_NETDEV_DEV?

=2DMichael Wu

--nextPart1806038.m4kecpxOFe
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFS8JdT3Oqt9AH4aERAqyzAKCyDxzv2bXifxzbY127IzHGMtG1+QCfddRi
EVx6uf1kZYWAeCD2ghlteTg=
=YS9j
-----END PGP SIGNATURE-----

--nextPart1806038.m4kecpxOFe--
