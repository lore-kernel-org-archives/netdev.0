From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/2] tests: Add test for 'ip route add default'
Date: Tue, 12 May 2015 17:40:16 +0300
Message-ID: <1431441616-25174-3-git-send-email-vadim4j@gmail.com>
References: <1431441616-25174-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34675 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932804AbbELOk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 10:40:58 -0400
Received: by wicmc15 with SMTP id mc15so55918987wic.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 07:40:57 -0700 (PDT)
In-Reply-To: <1431441616-25174-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/tests/ip/route/add_default_route.t | 12 ++++++++++++
 1 file changed, 12 insertions(+)
 create mode 100755 testsuite/tests/ip/route/add_default_route.t

diff --git a/testsuite/tests/ip/route/add_default_route.t b/testsuite/tests/ip/route/add_default_route.t
new file mode 100755
index 0000000..2908528
--- /dev/null
+++ b/testsuite/tests/ip/route/add_default_route.t
@@ -0,0 +1,12 @@
+#!/bin/sh
+
+source lib/generic.sh
+
+ts_log "[Testing add default route]"
+
+DEV=dummy0
+
+ts_ip "$0" "Add new interface $DEV" link add $DEV type dummy
+ts_ip "$0" "Set $DEV into UP state" link set up dev $DEV
+ts_ip "$0" "Add 1.1.1.1/24 addr on $DEV" addr add 1.1.1.1/24 dev $DEV
+ts_ip "$0" "Add default route via 1.1.1.1" route add default via 1.1.1.1
-- 
2.3.1
