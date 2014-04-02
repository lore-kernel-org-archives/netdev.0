From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [Patch net-next] pktgen: small code cleanup
Date: Wed,  2 Apr 2014 16:24:51 +0800
Message-ID: <1396427091-8230-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: davem@davemloft.net, Wei Yang <weiyang@linux.vnet.ibm.com>
To: fan.du@windriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:45949 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758097AbaDBIZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 04:25:15 -0400
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 2 Apr 2014 13:55:13 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 82B4F1258054
	for <netdev@vger.kernel.org>; Wed,  2 Apr 2014 13:57:38 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s328P2nl51183714
	for <netdev@vger.kernel.org>; Wed, 2 Apr 2014 13:55:02 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s328P55u005918
	for <netdev@vger.kernel.org>; Wed, 2 Apr 2014 13:55:06 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print the warning when the format is not correct.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 net/core/pktgen.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fdac61c..89d33c2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1767,7 +1767,7 @@ static ssize_t pktgen_thread_write(struct file *file,
 	char *pg_result;
 
 	if (count < 1) {
-		//      sprintf(pg_result, "Wrong command format");
+		pr_warn("WARNING: Wrong command format in %s\n", __func__);
 		return -EINVAL;
 	}
 
-- 
1.7.9.5
