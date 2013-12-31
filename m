From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH 1/2] ipv4: spaces required around that '='
Date: Tue, 31 Dec 2013 15:11:27 +0800
Message-ID: <1388473888-10860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:5291 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656Ab3LaHND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 02:13:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>


Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/proc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8ecd7ad..a6c8a80 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -333,22 +333,22 @@ static void icmp_put(struct seq_file *seq)
 	atomic_long_t *ptr = net->mib.icmpmsg_statistics->mibs;
 
 	seq_puts(seq, "\nIcmp: InMsgs InErrors InCsumErrors");
-	for (i=0; icmpmibmap[i].name != NULL; i++)
+	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " In%s", icmpmibmap[i].name);
 	seq_printf(seq, " OutMsgs OutErrors");
-	for (i=0; icmpmibmap[i].name != NULL; i++)
+	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " Out%s", icmpmibmap[i].name);
 	seq_printf(seq, "\nIcmp: %lu %lu %lu",
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INMSGS),
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INERRORS),
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_CSUMERRORS));
-	for (i=0; icmpmibmap[i].name != NULL; i++)
+	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
 			   atomic_long_read(ptr + icmpmibmap[i].index));
 	seq_printf(seq, " %lu %lu",
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
-	for (i=0; icmpmibmap[i].name != NULL; i++)
+	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
 			   atomic_long_read(ptr + (icmpmibmap[i].index | 0x100)));
 }
-- 
1.7.12
