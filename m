From: "Brenda J. Butler" <bjb@mojatatu.com>
Subject: [PATCH net-next] tc-testing: correction to docstring in get_unique_item
Date: Mon, 30 Oct 2017 20:37:49 -0400
Message-ID: <20171031003749.17928-1-bjb@mojatatu.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org,
        "Brenda J. Butler" <bjb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:51479 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbdJaAiE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 20:38:04 -0400
Received: by mail-io0-f175.google.com with SMTP id b186so31345780iof.8
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 17:38:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The docstring says the function returns a "set" but it returns
a "list".  These are both python data types, so we should refer to
the right one that is being returned.

Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
---
This patch was formerly sent as part of a 15-patch series.  It is being
split off as a stand-alone patch.

 tools/testing/selftests/tc-testing/tdc_helper.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/tc-testing/tdc_helper.py b/tools/testing/selftests/tc-testing/tdc_helper.py
index c3254f861fb2..6f99a4efe761 100644
--- a/tools/testing/selftests/tc-testing/tdc_helper.py
+++ b/tools/testing/selftests/tc-testing/tdc_helper.py
@@ -15,7 +15,7 @@ def get_categorized_testlist(alltests, ucat):
 
 
 def get_unique_item(lst):
-    """ For a list, return a set of the unique items in the list. """
+    """ For a list, return a list of the unique items in the list. """
     return list(set(lst))
 
 
-- 
2.15.0.rc0
