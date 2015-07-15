From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2015-07-15
Date: Wed, 15 Jul 2015 11:43:55 +0300
Message-ID: <20150715084355.GA13429@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:34298 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbbGOIoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 04:44:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's a regression fix for Broadcom Bluetooth adapters found at least
in certain Apple laptops. The issue was introduced in 4.1 so there's the
appropriate "Cc: stable" entry for it.

Let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit f760b87f8f12eb262f14603e65042996fe03720e:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-07-13 11:18:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 7bee8b08c428b63aa4a3765bb907602e36355378:

  Bluetooth: btbcm: allow btbcm_read_verbose_config to fail on Apple (2015-07-14 22:54:55 +0200)

----------------------------------------------------------------
Chris Mason (1):
      Bluetooth: btbcm: allow btbcm_read_verbose_config to fail on Apple

 drivers/bluetooth/btbcm.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)


--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVph1LAAoJECQj9vv5qNQSPzAP/RRFl+oyNaQIU6TjTO+mIled
lZQxIT1YmTRZ73P7LAACOe13zNqHgi8voFLoDKucMnvii4vQWdX0Mvb9I74rUMZN
KOFyBIFNGEHOtxqkz2QjfoLsNhwBhCAHJssUqi6mDGvouF6deO3VCvPBsPj+lxu2
D5DMLGDa5aK48KmyG1ZI2V1C/p/rgijdw+YhJPBjEfjYrmEQFX1ctsg+GUqKJQsH
DGEXMM18W3rpRBqxTwETh937bNk7EZoPVyqRqRO9V4Si/n9HvhB2/43cDTUvhBd4
C0cKdeDkgrP6TJZ7QiYm20Mo8B3nuoEyJXfGSkRCRS7TFJPgZfuCV098qAoraw/o
fLB6bsxw5qA99BTShb35k8Lek3pxUqU1lnAlbLI+Nq0we04erUTyeNEV0rreEnzo
jxtlnMEnE+z/X6b0WNx8ZlF6oRsIFIO/Dx5/3d366hJw9cJlJzICAqOOnx/K8ZjJ
rnogZI+cdI9ukrXR7JAAvPl/Jw667BQhw/nz7J0JcsRjzFQnp2gpyxdUfPE1GLdT
A6Ix97L6fdR73qQ64fzv95jqv2tjjnWplf4kFlF3ExchzX6JK6YTscNabTImv5QS
/JiGYFJqlV8I1GyuYQFgtMnzIpzeYzo6lfGu0QDmxZclK7t8+iDxIlX5uOkkcRHs
CE4dB8w6chQ7liIzWEsI
=iB/i
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--
