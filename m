From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH v2 1/4] net: snmp: fix the wrong ICMP_MIB_MAX value
Date: Thu, 02 Dec 2010 12:04:43 +0800
Message-ID: <4CF71ADB.5060702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Network-Maillist <netdev@vger.kernel.org>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60936 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756879Ab0LBEGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 23:06:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ICMP_MIB_MAX is equal to the total number of icmp mib,
So no need to add 1. This wastes 4/8 bytes memory.

Change it to be same as ICMP6_MIB_MAX, TCP_MIB_MAX, UDP_MIB_MAX.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/net/snmp.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index a0e6180..aebb553 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -61,8 +61,7 @@ struct ipstats_mib {
 
 /* ICMP */
 #define ICMP_MIB_DUMMY	__ICMP_MIB_MAX
-#define ICMP_MIB_MAX	(__ICMP_MIB_MAX + 1)
-
+#define ICMP_MIB_MAX	__ICMP_MIB_MAX
 struct icmp_mib {
 	unsigned long	mibs[ICMP_MIB_MAX];
 };
-- 
1.6.3.3
