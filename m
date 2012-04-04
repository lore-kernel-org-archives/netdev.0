From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/10] bnx2x: remove unnecessary .h dependencies
Date: Wed, 4 Apr 2012 07:41:23 +0300
Message-ID: <1333514492-20425-2-git-send-email-yuvalmin@broadcom.com>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4898 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594Ab2DDErX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 00:47:23 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    1 -
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    3 ---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    1 -
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f1f3ca6..0a95242 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -23,7 +23,6 @@
 #include <linux/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_checksum.h>
-#include <linux/firmware.h>
 #include <linux/prefetch.h>
 #include "bnx2x_cmn.h"
 #include "bnx2x_init.h"
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 2cc0a17..93b5fc4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -22,13 +22,10 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/crc32.h>
-
-
 #include "bnx2x.h"
 #include "bnx2x_cmn.h"
 #include "bnx2x_dump.h"
 #include "bnx2x_init.h"
-#include "bnx2x_sp.h"
 
 /* Note: in the format strings below %s is replaced by the queue-name which is
  * either its index or 'fcoe' for the fcoe queue. Make sure the format string
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f7f9aa8..c03e4ab 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -39,7 +39,6 @@
 #include <linux/time.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
-#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
-- 
1.7.9.rc2
