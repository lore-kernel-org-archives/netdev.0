From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2014-12-17
Date: Wed, 17 Dec 2014 22:46:14 +0200
Message-ID: <20141217204614.GA15480@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sm4nu43k4a2Rpi4c"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:47430 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaLQUqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 15:46:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's the first direct (i.e. skipping the wireless tree) bluetooth pull
request for you, intended for 3.19. It's just one patch: a fix from
Marcel for for remote service discovery filtering which also fixes a
'used uninitialized' compiler warning.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 65891feac27e26115dc4cce881743a1ac33372df:

  net: Disallow providing non zero VLAN ID for NIC drivers FDB add flow (2014-12-16 15:41:19 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to ea8ae2516ac43028a01c40b58ffa80d3b0afb802:

  Bluetooth: Fix bug with filter in service discovery optimization (2014-12-17 22:03:49 +0200)

----------------------------------------------------------------
Marcel Holtmann (1):
      Bluetooth: Fix bug with filter in service discovery optimization

 net/bluetooth/mgmt.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)


--sm4nu43k4a2Rpi4c
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUkeuWAAoJECQj9vv5qNQSG0wQAKs/rxSc+p+v15Cl93vjjNDX
kQGKomzrD8FYbFul7wFs63zB50yPR3enQr/93TyxDq5vMj+AD623sOBAUoYPsaSu
SebzOrGFnsOjhHTLNH++luQSQFu/8mzJbZRILJCgbADVZ3j9AHleIiLkkzE/E7vX
izGLu8MQl2hZsDU34JD4wPOSXHCO1TU4jrLipn2zit6MNe7ul165NfFeNjRtmnP8
6s9eh6SwMRWILQT/Rm55/kTD9GfwF+IPj3JPu56QJG3flqF0OUHtRvHMl+ZrMa4J
yGfI9ARhm9LW1l676Feg8OeqCQsE4Typ8xMUgPjaO9KoaJsqHJ8cnx96iGBbUTVQ
OdeYYeFbjdIQkM702bPo69hwezIzcOBK6KBdc2s4WaAtUNC1+F0KoFciFhMuLeLy
OVcqFcHsVon2DEpKwB9DBTNcr1uL2ATmMUunZIbeuIZYEMLQZdNnQjau2fSPchxV
+cmP/jdKUR/wP4XoffUEhyn//fc9WMSwtfiajqubBb/MCTRgfAQxHq0JsIVa2qpo
C0K2Nw2QL1XWXmr3xbxeTNT78M9G4iPqs5AcYH6llpfRruY2pY0P09JOjMMOvgin
Zx9iJ9TsHJmQNufBsAwxkyM8vrmqUiO3w7H/E6J0M7a1rB2YNFDmu9rmNJwMLSXQ
0fRuNgxzF4GaFKQiPzlY
=JkT0
-----END PGP SIGNATURE-----

--sm4nu43k4a2Rpi4c--
