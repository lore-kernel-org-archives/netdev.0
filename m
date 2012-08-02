From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] Makefile: add missing blankspace
Date: Thu, 2 Aug 2012 16:45:09 +0800
Message-ID: <1343897109-22855-1-git-send-email-lw@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Li Wei <lw@cn.fujitsu.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:12335 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab2HBIp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 04:45:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The missing blankspace caused us can't get tc.8 and tc-codel.8
installed.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 man/man8/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 1b671a4..c344094 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -3,7 +3,7 @@ TARGETS = ip-address.8 ip-link.8 ip-route.8
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc-bfifo.8 tc-cbq-details.8 tc-cbq.8 tc-drr.8 tc-htb.8 \
 	tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 tc-sfq.8 \
-	tc-tbf.8 tc.8tc-codel.8 tc-fq_codel.8 tc-sfb.8 tc-netem.8 tc-choke.8 \
+	tc-tbf.8 tc.8 tc-codel.8 tc-fq_codel.8 tc-sfb.8 tc-netem.8 tc-choke.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
 	ip-tunnel.8 ip-rule.8 ip-ntable.8 \
 	ip-monitor.8 tc-stab.8 tc-hfsc.8 ip-xfrm.8 ip-netns.8 \
-- 
1.7.10.1
