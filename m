From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] [drivers/net/cxgb3] removed several unneeded zero initilization
Date: Wed, 18 Jul 2007 15:24:49 +0800
Message-ID: <11847434891556-git-send-email-crquan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cr_quan@163.com, Denis Cheng <crquan@gmail.com>,
	linux-bugs@chelsio.com
To: linux-bugs@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:15067 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbXGRHYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 03:24:40 -0400
Received: by wa-out-1112.google.com with SMTP id v27so114888wah
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 00:24:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: linux-bugs@chelsio.com
Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 drivers/net/cxgb3/cxgb3_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 6fd1e52..45711f9 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -754,7 +754,7 @@ static int upgrade_fw(struct adapter *adap)
  */
 static int cxgb_up(struct adapter *adap)
 {
-	int err = 0;
+	int err;
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		err = t3_check_fw_version(adap);
@@ -861,7 +861,7 @@ static int offload_open(struct net_device *dev)
 	struct adapter *adapter = dev->priv;
 	struct t3cdev *tdev = T3CDEV(dev);
 	int adap_up = adapter->open_device_map & PORT_MASK;
-	int err = 0;
+	int err;
 
 	if (test_and_set_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map))
 		return 0;
@@ -1502,7 +1502,7 @@ static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		      u8 * data)
 {
 	u8 *buf;
-	int err = 0;
+	int err;
 	u32 aligned_offset, aligned_len, *p;
 	struct adapter *adapter = dev->priv;
 
-- 
1.5.2.2

