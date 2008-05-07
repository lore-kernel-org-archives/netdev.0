From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] NET: Remove PACKET_FASTROUTE
Date: Wed, 07 May 2008 17:07:10 +0800
Message-ID: <4821713E.7050308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51341 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753827AbYEGJJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 05:09:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we do not support fastroute anymore, remove macro PACKET_FASTROUTE.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 include/linux/if_packet.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index ad09609..d109a0f 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -30,7 +30,6 @@ struct sockaddr_ll
 #define PACKET_OUTGOING		4		/* Outgoing of any type */
 /* These ones are invisible by user level */
 #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
-#define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
 
 /* Packet socket options */
 
-- 
1.5.3.4

