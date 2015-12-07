From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 0/1] cxgb3: Convert simple_strtoul to kstrtox
Date: Mon,  7 Dec 2015 14:11:32 +0100
Message-ID: <1449493893-18055-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: santosh@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

Change since v1
- Always return kstrtox error code

LABBE Corentin (1):
  cxgb3: Convert simple_strtoul to kstrtox

 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 14 +++++++------
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c      | 28 ++++++++++++++++++-------
 2 files changed, 29 insertions(+), 13 deletions(-)

-- 
2.4.10
