From: Thomas Graf <tgraf@suug.ch>
Subject: [PKT_SCHED] atm: Fix missing net/netlink.h include after nlmsg_trim() cleanup
Date: Tue, 20 Mar 2007 23:02:25 +0100
Message-ID: <20070320220225.GP521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43592 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965AbXCTWCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 18:02:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sch_atm.c:(.text+0x380ed): undefined reference to `nlmsg_trim'

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 53060e6..daa1644 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -12,8 +12,8 @@
 #include <linux/atmdev.h>
 #include <linux/atmclip.h>
 #include <linux/netdevice.h>
-#include <linux/rtnetlink.h>
 #include <linux/file.h> /* for fput */
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/sock.h>
 
