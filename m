From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6 NET] Adjust RTATTR_MAX to IFLA_* changes
Date: Thu, 9 Sep 2004 18:31:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909163131.GA18951@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Eric Lemoine <eric.lemoine@gmail.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

IFLA_MAX is now bigger than RTA_MAX with the latest changes in IFLA_*.
Adjust RTATTR to point to IFLA_MAX to have big enough buffer in
rtnetlink_rcv_msg.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc1-bk15.orig/include/linux/rtnetlink.h	2004-09-08 18:32:05.000000000 +0200
+++ linux-2.6.9-rc1-bk15/include/linux/rtnetlink.h	2004-09-09 17:32:14.000000000 +0200
@@ -662,7 +662,7 @@
 
 /* SUMMARY: maximal rtattr understood by kernel */
 
-#define RTATTR_MAX		RTA_MAX
+#define RTATTR_MAX		IFLA_MAX
 
 /* RTnetlink multicast groups */
 
