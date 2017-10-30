From: "Brenda J. Butler" <bjb@mojatatu.com>
Subject: [PATCH net] tc-testing:  fix arg to ip command:  -s -> -n
Date: Mon, 30 Oct 2017 17:59:22 -0400
Message-ID: <20171030215922.14250-1-bjb@mojatatu.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com,
        netdev@vger.kernel.org, "Brenda J. Butler" <bjb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:51858 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751700AbdJ3V7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:59:54 -0400
Received: by mail-io0-f195.google.com with SMTP id b186so30657812iof.8
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:59:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 31c2611b66e0 ("selftests: Introduce a new test case to tc testsuite")
Fixes: 76b903ee198d ("selftests: Introduce tc testsuite")
Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
---

We want to run the command inside the container, not in the host.

 tools/testing/selftests/tc-testing/tdc.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/tc-testing/tdc.py b/tools/testing/selftests/tc-testing/tdc.py
index 5f11f5d7456e..a8981c5d0aaf 100755
--- a/tools/testing/selftests/tc-testing/tdc.py
+++ b/tools/testing/selftests/tc-testing/tdc.py
@@ -152,11 +152,11 @@ def ns_create():
         exec_cmd(cmd, False)
         cmd = 'ip link set $DEV0 up'
         exec_cmd(cmd, False)
-        cmd = 'ip -s $NS link set $DEV1 up'
+        cmd = 'ip -n $NS link set $DEV1 up'
         exec_cmd(cmd, False)
         cmd = 'ip link set $DEV2 netns $NS'
         exec_cmd(cmd, False)
-        cmd = 'ip -s $NS link set $DEV2 up'
+        cmd = 'ip -n $NS link set $DEV2 up'
         exec_cmd(cmd, False)
 
 
-- 
2.15.0.rc0
