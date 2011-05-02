From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] libertas: cleanup logging styles
Date: Mon,  2 May 2011 16:49:13 -0700
Message-ID: <cover.1304379925.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>, libertas-dev@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (2):
  libertas: Convert lbs_pr_<level> to pr_<level>
  libertas: Use netdev_<level> or dev_<level> where possible

Compiled but otherwise untested.

 drivers/net/wireless/libertas/cfg.c     |   16 +++---
 drivers/net/wireless/libertas/cmd.c     |   40 +++++++++------
 drivers/net/wireless/libertas/cmdresp.c |   27 ++++++----
 drivers/net/wireless/libertas/debugfs.c |    5 +-
 drivers/net/wireless/libertas/defs.h    |    7 ---
 drivers/net/wireless/libertas/if_cs.c   |   57 ++++++++++++---------
 drivers/net/wireless/libertas/if_sdio.c |   37 +++++++-------
 drivers/net/wireless/libertas/if_spi.c  |   83 +++++++++++++++++--------------
 drivers/net/wireless/libertas/if_usb.c  |   44 +++++++++-------
 drivers/net/wireless/libertas/main.c    |   42 +++++++++-------
 drivers/net/wireless/libertas/mesh.c    |    8 ++-
 drivers/net/wireless/libertas/rx.c      |    7 ++-
 12 files changed, 206 insertions(+), 167 deletions(-)

-- 
1.7.5.rc3.dirty
