From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] Use TASK_COMM_LEN macro.
Date: Thu, 10 Feb 2005 13:59:16 +0900 (JST)
Message-ID: <20050210.135916.65691686.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use TASK_COMM_LEN macro instead of magic number 16.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/core/sock.c 1.57 vs edited =====
--- 1.57/net/core/sock.c	2005-01-11 05:23:56 +09:00
+++ edited/net/core/sock.c	2005-02-10 13:53:08 +09:00
@@ -166,7 +166,7 @@
 static void sock_warn_obsolete_bsdism(const char *name)
 {
 	static int warned;
-	static char warncomm[16];
+	static char warncomm[TASK_COMM_LEN];
 	if (strcmp(warncomm, current->comm) && warned < 5) { 
 		strcpy(warncomm,  current->comm); 
 		printk(KERN_WARNING "process `%s' is using obsolete "

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
