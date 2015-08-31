From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH] ipv4: fix 32b build
Date: Mon, 31 Aug 2015 15:46:07 +0300
Message-ID: <1441025167-13740-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <davem@davemloft.net>, <raghavendra.kt@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0106.outbound.protection.outlook.com ([207.46.100.106]:35033
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752972AbbHaMr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 08:47:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Address remaining issue after 80ec192.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 net/ipv4/af_inet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c2d0ebc..96773a2 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1496,7 +1496,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		res += snmp_get_cpu_field(mib, cpu, offt, syncp_offset);
+		res += snmp_get_cpu_field64(mib, cpu, offt, syncp_offset);
 	}
 	return res;
 }
-- 
1.7.11.7
