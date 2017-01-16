From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2017-01-16
Date: Mon, 16 Jan 2017 09:58:31 +0200
Message-ID: <20170116075831.GA7190@x1c>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33619 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750840AbdAPH6k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 02:58:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are a couple of important 802.15.4 driver fixes for the 4.10
kernel.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 8a430ed50bb1b19ca14a46661f3b1b35f2fb5c39:

  net: ipv4: fix table id in getroute response (2017-01-12 15:18:20 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 8e38b7d4d71479b23b77f01cf0e5071610b8f357:

  ieee802154: atusb: fix driver to work with older firmware versions (2017-01-12 22:12:43 +0100)

----------------------------------------------------------------
Andrey Smirnov (1):
      at86rf230: Allow slow GPIO pins for "rstn"

Stefan Schmidt (4):
      ieee802154: atusb: do not use the stack for buffers to make them DMA able
      ieee802154: atusb: make sure we set a randaom extended address if fetching fails
      ieee802154: atusb: do not use the stack for address fetching to make it DMA able
      ieee802154: atusb: fix driver to work with older firmware versions

 drivers/net/ieee802154/at86rf230.c |  4 +--
 drivers/net/ieee802154/atusb.c     | 59 +++++++++++++++++++++++---------
 2 files changed, 45 insertions(+), 18 deletions(-)

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYfH0nAAoJECQj9vv5qNQS9mgP/3eKGzRp7JB77D5A64JvfVhB
tLfK/7mO2u67Oaje0kG06UwXFmCYOXH/i3MtX/SeLn44lpC7d9GNYFdYozkt4cz0
pNVRhTJZzqJTMKcrPrl2XbL0bczP+C+CJ+3FOjJYCUvTDXehm4hHF+K30h0Jk9ES
ZF+ArOJSRumn7uCNLm9qh2nVqq6HsCcyIJdWzm6T7ARk0SGYwoJfb/OmqqMFEo2j
rRbwI53l7cXgOe1BpS1zQWlwbOUR2ro6gBixyKx1YVEoUz5BdWOZPBw/85T9Jq5+
r2eybdUg4bW6OjP64IBO8JniQ5249pTbB9WC5Y0JZRQ617oyDRWYucrilTVzlKdX
Qyx6Daevd/aQPIjEmfNTNQNjl4+nJmQrhD6ZDFSprkfAA/yRhIHISwq7FPO7g/8y
4Xxd5z/GUmQUsGojFGohxwFcGSXj8pEYTekBoejRvw9Q+0VfMPq+BLLb64tOXwdq
PdoScLgU6cM/F2Bugqh5zrft301NnM1RRwvpq3V5RdtwfdHCvod8eYGfWr3TtaFk
/8a40JdNEIsF+up3gIYyP7jlKCzG009J2UTzickfArvx20QWfEZ6npEAkmrVdAHx
wBp4IVL+WN/hRi0zAIKcJSllSeEOCKcZ09ICJnkuvcRIGFWVNoAmBlKidjagUw6x
6faTvYaapEY35WglZCEg
=64Oe
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--
