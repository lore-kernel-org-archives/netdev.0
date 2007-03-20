From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 06/31] [NETLINK]: Add missing include net/netlink.h to sch_atm.c
Date: Tue, 20 Mar 2007 19:54:52 -0300
Message-ID: <20070320225452.GS17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:25953 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbXCTWy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 18:54:56 -0400
Received: by wx-out-0506.google.com with SMTP id h31so60697wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 15:54:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Leftover from the nlmsg_trim cset.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/sched/sch_atm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 53060e6..0cc3c9b 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/file.h> /* for fput */
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/sock.h>
 
-- 
1.5.0.3

