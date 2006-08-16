From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH 2/2] Don't rely on linux/if_arp.h being included by other headers
Date: Tue, 15 Aug 2006 20:45:03 -0400
Message-ID: <20060816004503.3035.14638.stgit@dv.roinet.com>
References: <20060816004500.3035.77174.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-64-105-159-118.phlapafg.covad.net ([64.105.159.118]:19686
	"EHLO smtp.roinet.com") by vger.kernel.org with ESMTP
	id S1750748AbWHPApJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 20:45:09 -0400
Received: from dv.roinet.com (192.168.1.21 [192.168.1.21])
    by smtp.roinet.com with SMTP;
    for netdev@vger.kernel.org;
    Tue, 15 Aug 2006 20:49:17 -0400 (EDT)
    (envelope-from proski@gnu.org)
To: netdev@vger.kernel.org
In-Reply-To: <20060816004500.3035.77174.stgit@dv.roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>


---

 drivers/net/wireless/orinoco.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 317ace7..1174ff5 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -82,6 +82,7 @@ #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 #include <net/ieee80211.h>
