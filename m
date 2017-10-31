From: "Brenda J. Butler" <bjb@mojatatu.com>
Subject: [PATCH net-next] tc-testing: gitignore, ignore standard python artifacts
Date: Tue, 31 Oct 2017 14:26:54 -0400
Message-ID: <20171031182654.9674-1-bjb@mojatatu.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org,
        "Brenda J. Butler" <bjb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:53409 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932628AbdJaS1C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:27:02 -0400
Received: by mail-io0-f196.google.com with SMTP id 189so792806iow.10
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:27:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ignore .pyc files, "python compiled" files, that get created
when a python script is run.  They should never be committed.

Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
---
 tools/testing/selftests/tc-testing/.gitignore | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/testing/selftests/tc-testing/.gitignore b/tools/testing/selftests/tc-testing/.gitignore
index c18dd8d83cee..7a60b85e148f 100644
--- a/tools/testing/selftests/tc-testing/.gitignore
+++ b/tools/testing/selftests/tc-testing/.gitignore
@@ -1 +1,2 @@
 __pycache__/
+*.pyc
-- 
2.15.0.rc0
