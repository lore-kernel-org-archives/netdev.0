From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] net: igb: fix the start time for periodic output
 signals
Date: Thu, 11 Jun 2015 15:59:05 -0700
Message-ID: <1434063545.3530.11.camel@intel.com>
References: <1434027090-26866-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-stsQaRcQHHhNfTpacGzy"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62957 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219AbbFKW7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 18:59:07 -0400
In-Reply-To: <1434027090-26866-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-stsQaRcQHHhNfTpacGzy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-06-11 at 14:51 +0200, Richard Cochran wrote:
> When programming the start of a periodic output, the code wrongly
> places
> the seconds value into the "low" register and the nanoseconds into the
> "high" register.  Even though this is backwards, it slipped through my
> testing, because the re-arming code in the interrupt service routine
> is
> correct, and the signal does appear starting with the second edge.
>=20
> This patch fixes the issue by programming the registers correctly.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-stsQaRcQHHhNfTpacGzy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVehK5AAoJEOVv75VaS+3OaQ4P/2noDle5dXV6xb6Sg098BDaP
GF9uSb0qIyCb9QMRZKOyqDYmk+1S6OBT6aaDlxVCznyKBLznTYaE5DkLRuzI6FFZ
6WFB2NPiPHpvHuJEMKfarjcIdSnLw+RuN+9AI57Oe4RHJKnyBWjsn3ftLwJ4cBMQ
vqBcNLgD2F8+kxoMwAMdKrFU+KDaYBieK9zgCxaFtUGQ0+wtnhUr4uARI3QMSswN
+PjAW981DWsYRH2dBsx3WquAlJvqnIDMCUsZrWt93U5XvKdrvXLHWZh3Dx3xCl+T
BvRalRIxkCz1D1hoj/NXMCx6QiNpWq4KHx7FbBz7H/ODv8GG2mRzbwRgNyT6Ct2O
jvl3TTeL4BhRAdDUPsr9VEIMUD/Z94nwspjtMeMzeTQJYh+qBjaimn/CGmg+vxxh
p4xcbgt5WGm68qmoLVJvm+4yIO1hSg4JA/qn8KB90YXAGT/dhCLp4j8oVIepbGUi
CZpSIAJIZ2fj//mJ7A/SfpTzo6OatKbIVF11+vUu2yQOgjNTXd50sWhlsohVukOT
lyF2Lhep4EPD54afL3nXm4qwT+O6nWu+9IZYqXylFMdrDZ1SmVgiZiVKGOYxfLEH
+sRYML1GXN7uC686ZimSrJWmjtWEGU8j4QQbiG4FqUa1kRWT4FBj5pP9RjOqBJ+w
W1UhMHeEKEoJ5/ujp/7d
=aVRQ
-----END PGP SIGNATURE-----

--=-stsQaRcQHHhNfTpacGzy--
