From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] igb: reduce Rx header size
Date: Thu, 02 Aug 2012 17:15:38 +0200
Message-ID: <1343920538.9299.200.camel@edumazet-glaptop>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1342912142-11130-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34350 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab2HBPPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 11:15:43 -0400
Received: by bkwj10 with SMTP id j10so4305409bkw.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 08:15:42 -0700 (PDT)
In-Reply-To: <1342912142-11130-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Reduce skb truesize by 256 bytes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
Tested on my machine without any problem

 drivers/net/ethernet/intel/igb/igb.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 9e572dd..0c9f62c 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -131,9 +131,9 @@ struct vf_data_storage {
 #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
 
 /* Supported Rx Buffer Sizes */
-#define IGB_RXBUFFER_512   512
+#define IGB_RXBUFFER_256   256
 #define IGB_RXBUFFER_16384 16384
-#define IGB_RX_HDR_LEN     IGB_RXBUFFER_512
+#define IGB_RX_HDR_LEN     IGB_RXBUFFER_256
 
 /* How many Tx Descriptors do we need to call netif_wake_queue ? */
 #define IGB_TX_QUEUE_WAKE	16
