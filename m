From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH net-next 1/3] if_ether: add forces ife lfb type
Date: Mon, 28 Aug 2017 15:03:13 -0400
Message-ID: <20170828190315.26646-2-aring@mojatatu.com>
References: <20170828190315.26646-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35943 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbdH1TEa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:04:30 -0400
Received: by mail-io0-f193.google.com with SMTP id v96so1084474ioi.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:04:30 -0700 (PDT)
In-Reply-To: <20170828190315.26646-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the forces IFE lfb type according to IEEE registered
ethertypes. See http://standards-oui.ieee.org/ethertype/eth.txt for more
information. Since there exists the IFE subsystem it can be used there.

This patch also use the correct word "ForCES" instead of "FoRCES" which
is a spelling error inside the IEEE ethertype specification.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 include/uapi/linux/if_ether.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 5bc9bfd816b7..22bf8effefef 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -103,6 +103,7 @@
 #define ETH_P_QINQ2	0x9200		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_QINQ3	0x9300		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
+#define ETH_P_IFE	0xED3E		/* ForCES inter-FE LFB type */
 #define ETH_P_AF_IUCV   0xFBFB		/* IBM af_iucv [ NOT AN OFFICIALLY REGISTERED ID ] */
 
 #define ETH_P_802_3_MIN	0x0600		/* If the value in the ethernet type is less than this value
-- 
2.11.0
