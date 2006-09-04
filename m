From: "Wong Edison" <hswong3i@gmail.com>
Subject: [PATCH 1/2] tcp-lp 2.6.18-rc6: update document
Date: Mon, 4 Sep 2006 17:45:05 +0800
Message-ID: <3feffd230609040245jd20b3dfj495bb5279528e7e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:51595 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751281AbWIDJpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 05:45:05 -0400
Received: by py-out-1112.google.com with SMTP id n25so2554679pyg
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2006 02:45:05 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we have setup the project page within SourceForge, here is some
update to the document.

Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

---

diff -urpN 2.6.18-rc6/tcp_lp.c tcp-lp/tcp_lp.c
--- 2.6.18-rc6/tcp_lp.c    2006-09-04 16:21:00.000000000 +0800
+++ tcp-lp/tcp_lp.c    2006-09-04 17:22:19.000000000 +0800
@@ -3,13 +3,8 @@
  *
  * TCP Low Priority is a distributed algorithm whose goal is to utilize only
  *   the excess network bandwidth as compared to the ``fair share`` of
- *   bandwidth as targeted by TCP. Available from:
- *     http://www.ece.rice.edu/~akuzma/Doc/akuzma/TCP-LP.pdf
+ *   bandwidth as targeted by TCP.
  *
- * Original Author:
- *   Aleksandar Kuzmanovic <akuzma@northwestern.edu>
- *
- * See http://www-ece.rice.edu/networks/TCP-LP/ for their implementation.
  * As of 2.6.13, Linux supports pluggable congestion control algorithms.
  * Due to the limitation of the API, we take the following changes from
  * the original TCP-LP implementation:
@@ -24,11 +19,20 @@
  *   o OWD is handled in relative format, where local time stamp will in
  *     tcp_time_stamp format.
  *
- * Port from 2.4.19 to 2.6.16 as module by:
- *   Wong Hoi Sing Edison <hswong3i@gmail.com>
- *   Hung Hing Lun <hlhung3i@gmail.com>
+ * Original Author:
+ *   Aleksandar Kuzmanovic <akuzma@northwestern.edu>
+ * Available from:
+ *   http://www.ece.rice.edu/~akuzma/Doc/akuzma/TCP-LP.pdf
+ * Original implementation for 2.4.19:
+ *   http://www-ece.rice.edu/networks/TCP-LP/
+ *
+ * 2.6.x module Authors:
+ *   Wong Hoi Sing, Edison <hswong3i@gmail.com>
+ *   Hung Hing Lun, Mike <hlhung3i@gmail.com>
+ * SourceForge project page:
+ *   http://tcp-lp-mod.sourceforge.net/
  *
- * Version: $Id: tcp_lp.c,v 1.22 2006-05-02 18:18:19 hswong3i Exp $
+ * Version: $Id: tcp_lp.c,v 1.23 2006/09/04 09:13:22 hswong3i Exp $
  */

 #include <linux/config.h>
@@ -333,6 +340,6 @@ static void __exit tcp_lp_unregister(voi
 module_init(tcp_lp_register);
 module_exit(tcp_lp_unregister);

-MODULE_AUTHOR("Wong Hoi Sing Edison, Hung Hing Lun");
+MODULE_AUTHOR("Wong Hoi Sing Edison, Hung Hing Lun Mike");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("TCP Low Priority");

-- 
VGER BF report: U 0.528777
