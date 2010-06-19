From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] b43: logging cleanups
Date: Sat, 19 Jun 2010 16:30:08 -0700
Message-ID: <cover.1276988387.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just some small cleanups

Joe Perches (3):
  drivers/net/wireless/b43: Use local ratelimit_state
  drivers/net/wireless/b43: Logging cleanups
  drivers/net/wireless/b43: Rename b43_debug to b43_debugging

 drivers/net/wireless/b43/b43.h        |   17 +--
 drivers/net/wireless/b43/debugfs.c    |   16 +-
 drivers/net/wireless/b43/debugfs.h    |    4 +-
 drivers/net/wireless/b43/dma.c        |  125 ++++++++---------
 drivers/net/wireless/b43/leds.c       |    6 +-
 drivers/net/wireless/b43/lo.c         |   37 +++---
 drivers/net/wireless/b43/main.c       |  252 +++++++++++++++++----------------
 drivers/net/wireless/b43/pcmcia.c     |    3 +-
 drivers/net/wireless/b43/phy_a.c      |   11 +-
 drivers/net/wireless/b43/phy_common.c |    7 +-
 drivers/net/wireless/b43/phy_g.c      |   62 ++++----
 drivers/net/wireless/b43/phy_lp.c     |   17 ++-
 drivers/net/wireless/b43/phy_n.c      |   30 ++--
 drivers/net/wireless/b43/pio.c        |   12 +-
 drivers/net/wireless/b43/rfkill.c     |    4 +-
 drivers/net/wireless/b43/sysfs.c      |    3 +-
 drivers/net/wireless/b43/xmit.c       |   10 +-
 17 files changed, 304 insertions(+), 312 deletions(-)
