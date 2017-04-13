From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] MAINTAINERS: rename TC entry and add couple of header files
Date: Thu, 13 Apr 2017 18:13:51 +0200
Message-ID: <1492100031-13462-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, mlxsw@mellanox.com, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34416 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752935AbdDMQNy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:13:54 -0400
Received: by mail-wm0-f66.google.com with SMTP id x75so13417378wma.1
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 09:13:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The section is not specific only to "TC classifiers", but applies to the
whole TC subsystem. Also, add couple of forgotten headers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 MAINTAINERS | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5397f54..549e8e1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -12180,12 +12180,17 @@ F:	Documentation/accounting/taskstats*
 F:	include/linux/taskstats*
 F:	kernel/taskstats.c
 
-TC CLASSIFIER
+TC subsystem
 M:	Jamal Hadi Salim <jhs@mojatatu.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	include/net/pkt_cls.h
+F:	include/net/pkt_sched.h
+F:	include/net/tc_act/
 F:	include/uapi/linux/pkt_cls.h
+F:	include/uapi/linux/pkt_sched.h
+F:	include/uapi/linux/tc_act/
+F:	include/uapi/linux/tc_ematch/
 F:	net/sched/
 
 TCP LOW PRIORITY MODULE
-- 
2.7.4
