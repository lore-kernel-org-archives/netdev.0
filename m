From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next] tc: ife: correct spelling of prio in example
Date: Wed, 11 Jan 2017 14:10:16 +0100
Message-ID: <1484140216-19142-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
        Lucas Bates <lucasb@mojatatu.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56973 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966467AbdAKNK3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 08:10:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct typo in example in ife man page.

Fixes: 06f9a59170c0 ("man: tc-ife.8: man page for ife action")
Cc: Lucas Bates <lucasb@mojatatu.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-ife.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/tc-ife.8 b/man/man8/tc-ife.8
index aaf0f97d5c8d..dae8b9be9bcb 100644
--- a/man/man8/tc-ife.8
+++ b/man/man8/tc-ife.8
@@ -99,7 +99,7 @@ classification so that it will match ICMP on the next rule, at prio 3:
 # tc filter add dev eth0 parent ffff: prio 2 protocol 0xdead \\
 	u32 match u32 0 0 flowid 1:1 \\
 	action ife decode reclassify
-# tc filter add dev eth0 parent ffff: priod 3 protocol ip \\
+# tc filter add dev eth0 parent ffff: prio 3 protocol ip \\
 	u32 match ip protocol 0xff flowid 1:1 \\
 	action continue
 .EE
-- 
2.7.0.rc3.207.g0ac5344
