From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 2/3] net: snmp: fix the wrong ICMP_MIB_MAX value
Date: Mon, 29 Nov 2010 14:53:55 +0800
Message-ID: <4CF34E03.8020504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Network-Maillist <netdev@vger.kernel.org>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59679 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751275Ab0K2Gzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 01:55:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ICMP_MIB_MAX is equal to the total number of icmp mib,
So no need to add 1. This wastes 4/8 bytes memory.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/net/snmp.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index 835c587..762e2ab 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -60,8 +60,7 @@ struct ipstats_mib {
 };
 
 /* ICMP */
-#define ICMP_MIB_MAX	(__ICMP_MIB_MAX + 1)
-
+#define ICMP_MIB_MAX	__ICMP_MIB_MAX
 struct icmp_mib {
 	unsigned long	mibs[ICMP_MIB_MAX];
 };
-- 
1.6.3.3
