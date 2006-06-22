From: Michael Wu <michael.wu@mozilla.com>
Subject: Re: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Thu, 22 Jun 2006 09:44:59 -0700
Message-ID: <200606220945.08026.michael.wu@mozilla.com>
References: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3534246.qZn2rRzACq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:63905 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1750972AbWFVQpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 12:45:17 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3534246.qZn2rRzACq
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 22 June 2006 05:12, Luis R. Rodriguez wrote:
> (3) On resume() talk to userspace via netlink to read our sysfs and
> configfs us
>
I think that's fairly overkill. I really do not like the idea of requiring =
any=20
more userspace involvement in the suspend process than needed. At least for=
=20
ADM8211, all the data needed to restore the card properly is already stored=
=20
somewhere for userspace (iwconfig) to query, so I don't understand how this=
=20
is suppose to reduce bloat. All the data that is needed should already be=20
stored in the driver to support configuring the interface before taking the=
=20
interface up.

=2DMichael Wu

--nextPart3534246.qZn2rRzACq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEmskTT3Oqt9AH4aERAhzKAKCplAyFAM9XEsL+XZPVOkseWkYV5gCg0mHW
RaReQO4dPN5QqRZfNZBBj4I=
=PhO3
-----END PGP SIGNATURE-----

--nextPart3534246.qZn2rRzACq--
