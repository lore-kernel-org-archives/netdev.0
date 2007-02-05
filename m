From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 2.6.20] e1000: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 18:55:46 +0200
Message-ID: <20070205165546.GE3896@Ahmed>
References: <20070205165429.GD3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cramerj@intel.com, john.ronciak@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751649AbXBEQzy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070205165429.GD3896@Ahmed>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A patch to use ARRAY_SIZE macro already defined in kernel.h.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
Patch is compile tested.

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index fb96c87..d21706e 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -746,7 +746,7 @@ err_setup:
 	uint32_t pat, value;                                                   \
 	uint32_t test[] =                                                      \
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};              \
-	for (pat = 0; pat < sizeof(test)/sizeof(test[0]); pat++) {              \
+	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {              \
 		E1000_WRITE_REG(&adapter->hw, R, (test[pat] & W));             \
 		value = E1000_READ_REG(&adapter->hw, R);                       \
 		if (value != (test[pat] & W & M)) {                             \

-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
