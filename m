From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 1/4] inet: include net/sock.h in inet_common.h
Date: Thu,  3 Aug 2017 12:31:41 -0700
Message-ID: <20170803193144.24108-2-tom@quantonium.net>
References: <20170803193144.24108-1-tom@quantonium.net>
Cc: rohit@quantonium.net, davejwatson@fb.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:32851 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbdHCTcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 15:32:07 -0400
Received: by mail-pf0-f182.google.com with SMTP id d67so10088501pfc.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 12:32:06 -0700 (PDT)
In-Reply-To: <20170803193144.24108-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_common.h has a dependency on sock.h so it should include that.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/net/inet_common.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index f39ae697347f..df0119a317aa 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -1,6 +1,8 @@
 #ifndef _INET_COMMON_H
 #define _INET_COMMON_H
 
+#include <net/sock.h>
+
 extern const struct proto_ops inet_stream_ops;
 extern const struct proto_ops inet_dgram_ops;
 
-- 
2.11.0
