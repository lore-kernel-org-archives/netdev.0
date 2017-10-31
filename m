From: "Brenda J. Butler" <bjb@mojatatu.com>
Subject: [PATCH net-next] tc-testing: better check if thing is list
Date: Tue, 31 Oct 2017 14:28:35 -0400
Message-ID: <20171031182835.9834-1-bjb@mojatatu.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org,
        "Brenda J. Butler" <bjb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:52863 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932766AbdJaS2l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:28:41 -0400
Received: by mail-io0-f182.google.com with SMTP id f20so816676ioj.9
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:28:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check if tcase[k] is an instance of a list (is or is derived from list)
instead of checking if it is a list.

This will be useful if the data structures change to be something
that implements list, instead of being an actual list.  In that
case, this code will not have to change.

Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
---
 tools/testing/selftests/tc-testing/tdc_helper.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/tc-testing/tdc_helper.py b/tools/testing/selftests/tc-testing/tdc_helper.py
index c3254f861fb2..b4fbb0ce0cbe 100644
--- a/tools/testing/selftests/tc-testing/tdc_helper.py
+++ b/tools/testing/selftests/tc-testing/tdc_helper.py
@@ -57,7 +57,7 @@ def print_sll(items):
 def print_test_case(tcase):
     """ Pretty-printing of a given test case. """
     for k in tcase.keys():
-        if (type(tcase[k]) == list):
+        if (isinstance(tcase[k], list)):
             print(k + ":")
             print_list(tcase[k])
         else:
-- 
2.15.0.rc0
