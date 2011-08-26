From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] ath: Reduce logging message code size
Date: Fri, 26 Aug 2011 01:56:37 -0700
Message-ID: <cover.1314347556.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduces size ~5KB in an allyesconfig.

Joe Perches (2):
  ath: Make ath_dbg void not int
  ath: Make ath_printk void not int and remove unused struct ath_common *

 drivers/net/wireless/ath/ath.h  |   48 +++++++++++++++++++-------------------
 drivers/net/wireless/ath/main.c |    8 +-----
 2 files changed, 26 insertions(+), 30 deletions(-)

-- 
1.7.6.405.gc1be0
