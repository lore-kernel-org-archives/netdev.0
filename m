From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] - Wrong use of RTM_BASE in XFRM message types.
Date: Fri, 23 May 2003 11:14:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ECE64F2.5000300@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am using 2.5.68 and found XFRM_MSG_BASE being defined, but RTM_BASE used for
all XFRM messages, changed it. Current mailer (hopefully) shouldn't screw up
the tabs.

Thanks,

- KK

diff -ruN linux-2.5.68.org/include/linux/xfrm.h linux-2.5.68/include/linux/xfrm.h
--- linux-2.5.68.org/include/linux/xfrm.h	2003-05-23 11:02:27.000000000 -0700
+++ linux-2.5.68/include/linux/xfrm.h	2003-05-23 11:04:02.000000000 -0700
@@ -104,17 +104,17 @@
  /* Netlink configuration messages.  */
  #define XFRM_MSG_BASE		0x10

-#define XFRM_MSG_NEWSA		(RTM_BASE + 0)
-#define XFRM_MSG_DELSA		(RTM_BASE + 1)
-#define XFRM_MSG_GETSA		(RTM_BASE + 2)
-
-#define XFRM_MSG_NEWPOLICY	(RTM_BASE + 3)
-#define XFRM_MSG_DELPOLICY	(RTM_BASE + 4)
-#define XFRM_MSG_GETPOLICY	(RTM_BASE + 5)
-
-#define XFRM_MSG_ALLOCSPI	(RTM_BASE + 6)
-#define XFRM_MSG_ACQUIRE	(RTM_BASE + 7)
-#define XFRM_MSG_EXPIRE		(RTM_BASE + 8)
+#define XFRM_MSG_NEWSA		(XFRM_MSG_BASE + 0)
+#define XFRM_MSG_DELSA		(XFRM_MSG_BASE + 1)
+#define XFRM_MSG_GETSA		(XFRM_MSG_BASE + 2)
+
+#define XFRM_MSG_NEWPOLICY	(XFRM_MSG_BASE + 3)
+#define XFRM_MSG_DELPOLICY	(XFRM_MSG_BASE + 4)
+#define XFRM_MSG_GETPOLICY	(XFRM_MSG_BASE + 5)
+
+#define XFRM_MSG_ALLOCSPI	(XFRM_MSG_BASE + 6)
+#define XFRM_MSG_ACQUIRE	(XFRM_MSG_BASE + 7)
+#define XFRM_MSG_EXPIRE		(XFRM_MSG_BASE + 8)

  #define XFRM_MSG_MAX		(XFRM_MSG_EXPIRE+1)
