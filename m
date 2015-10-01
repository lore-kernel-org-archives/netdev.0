From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2015-10-01
Date: Thu, 01 Oct 2015 20:14:44 +0300
Message-ID: <87oagi5x4r.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

few very small fixes I would like to get to 4.3, nothing really special=
=2E
Please let me know if you have any problems.

Kalle

The following changes since commit bdb06cbf77cb01911694cc9076ffa8196b7b=
9b61:

  net: Fix panic in icmp_route_lookup (2015-09-25 21:44:02 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.=
git tags/wireless-drivers-for-davem-2015-10-01

for you to fetch changes up to 76d164f582150fd0259ec0fcbc485470bcd8033e=
:

  ath10k: fix DMA related firmware crashes on multiple devices (2015-09=
-26 20:48:25 +0300)

----------------------------------------------------------------
ath9k:

* declare required extra tx headroom

ath10k:

* fix DMA related firmware crashes on multiple devices

rt2800usb:

* add usb ID 1b75:3070 for Airlive WT-2000USB

b43:

* probe bcma core (device) rev 0x15

----------------------------------------------------------------
=46elix Fietkau (2):
      ath9k: declare required extra tx headroom
      ath10k: fix DMA related firmware crashes on multiple devices

Rafa=C5=82 Mi=C5=82ecki (1):
      b43: probe bcma core (device) rev 0x15

Stanislaw Gruszka (1):
      rt2800usb: add usb ID 1b75:3070 for Airlive WT-2000USB

 drivers/net/wireless/ath/ath10k/hw.h    |    4 ++--
 drivers/net/wireless/ath/ath9k/init.c   |    1 +
 drivers/net/wireless/b43/main.c         |    1 +
 drivers/net/wireless/rt2x00/rt2800usb.c |    1 +
 4 files changed, 5 insertions(+), 2 deletions(-)

--=20
Kalle Valo
