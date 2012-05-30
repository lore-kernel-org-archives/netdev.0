From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/4] treewide: Fix likely misuses of | for &
Date: Wed, 30 May 2012 13:25:53 -0700
Message-ID: <cover.1338408931.git.joe@perches.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| with a non-zero constant is always true.
Likely these should have been &.

Joe Perches (4):
  mac80211: Fix likely misuse of | for &
  can: cc770: Fix likely misuse of | for &
  brcmfmac: Fix likely misuse of | for &
  usb: gadget: pch_udc: Fix likely misuse of | for &

 drivers/net/can/cc770/cc770_platform.c           |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    4 ++--
 drivers/usb/gadget/pch_udc.c                     |    2 +-
 net/mac80211/cfg.c                               |    6 +++---
 4 files changed, 7 insertions(+), 7 deletions(-)

-- 
1.7.8.111.gad25c.dirty

