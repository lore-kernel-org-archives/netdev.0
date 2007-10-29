From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6.24-rc] [IPV6] NDISC: Fix setting base_reachable_time_ms
 variable.
Date: Mon, 29 Oct 2007 11:49:54 +0900 (JST)
Message-ID: <20071029.114954.02253064.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	usagi-core@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36674 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbXJ2Cto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 22:49:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This bug was introduced by the commit
d12af679bcf8995a237560bdf7a4d734f8df5dbb.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 20cfc90..36f7dbf 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1670,7 +1670,7 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, struct file * f
 					    filp, buffer, lenp, ppos);
 
 	else if ((strcmp(ctl->procname, "retrans_time_ms") == 0) ||
-		 (strcmp(ctl->procname, "base_reacable_time_ms") == 0))
+		 (strcmp(ctl->procname, "base_reachable_time_ms") == 0))
 		ret = proc_dointvec_ms_jiffies(ctl, write,
 					       filp, buffer, lenp, ppos);
 	else

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
