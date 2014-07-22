From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 2/3] ethtool: add rx_copybreak support
Date: Tue, 22 Jul 2014 23:01:07 +0530
Message-ID: <1406050268-13329-3-git-send-email-_govind@gmx.com>
References: <1406050268-13329-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:58463 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755408AbaGVRcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 13:32:05 -0400
In-Reply-To: <1406050268-13329-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds rx_copybreak support to ethtool.h header file.
This is used to show/set rx_copybreak using ethtool.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 include/uapi/linux/ethtool.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index e3c7a71..d2912ad 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -433,10 +433,12 @@ struct ethtool_ringparam {
 	__u32	rx_mini_max_pending;
 	__u32	rx_jumbo_max_pending;
 	__u32	tx_max_pending;
+	__u32	rx_max_copybreak_pending;
 	__u32	rx_pending;
 	__u32	rx_mini_pending;
 	__u32	rx_jumbo_pending;
 	__u32	tx_pending;
+	__u32	rx_copybreak_pending;
 };
 
 /**
-- 
2.0.2
