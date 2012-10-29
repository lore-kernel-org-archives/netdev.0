From: Jason Wang <jasowang@redhat.com>
Subject: [net-next v4 4/7] tuntap: introduce multiqueue flags
Date: Mon, 29 Oct 2012 13:36:01 +0800
Message-ID: <1351488964-11109-6-git-send-email-jasowang__31498.6216057607$1351489588$gmane$org@redhat.com>
References: <1351488964-11109-1-git-send-email-jasowang@redhat.com>
Cc: maxk@qualcomm.com, haixiao@juniper.net, ernesto.martin@viasat.com,
	krkumar2@in.ibm.com, edumazet@google.com,
	Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33347 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754856Ab2J2Foc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 01:44:32 -0400
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
In-Reply-To: <1351488964-11109-1-git-send-email-jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add flags to be used by creating multiqueue tuntap device.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/uapi/linux/if_tun.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 25a585c..8ef3a87 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -34,6 +34,7 @@
 #define TUN_ONE_QUEUE	0x0080
 #define TUN_PERSIST 	0x0100	
 #define TUN_VNET_HDR 	0x0200
+#define TUN_TAP_MQ      0x0400
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -61,6 +62,7 @@
 #define IFF_ONE_QUEUE	0x2000
 #define IFF_VNET_HDR	0x4000
 #define IFF_TUN_EXCL	0x8000
+#define IFF_MULTI_QUEUE 0x0100
 
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
-- 
1.7.1
