From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/9] PKT_SCHED: rtattr_parse shortcut for nested TLVs
Date: Thu, 30 Dec 2004 13:28:51 +0100
Message-ID: <20041230122851.GN32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041230122652.GM32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10.orig/include/linux/rtnetlink.h	2004-12-25 23:21:18.000000000 +0100
+++ linux-2.6.10/include/linux/rtnetlink.h	2004-12-26 19:52:21.000000000 +0100
@@ -756,6 +756,9 @@
 
 extern int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len);
 
+#define rtattr_parse_nested(tb, max, rta) \
+	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
+
 extern struct sock *rtnl;
 
 struct rtnetlink_link
