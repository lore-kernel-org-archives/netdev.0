From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 1/4] inet: include net/sock.h in inet_common.h
Date: Tue,  1 Aug 2017 19:53:01 -0700
Message-ID: <20170802025304.1862-2-tom@quantonium.net>
References: <20170802025304.1862-1-tom@quantonium.net>
Cc: rohit@quantonium.net, davejwatson@fb.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34968 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdHBCx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 22:53:58 -0400
Received: by mail-pg0-f49.google.com with SMTP id v189so15472307pgd.2
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 19:53:58 -0700 (PDT)
In-Reply-To: <20170802025304.1862-1-tom@quantonium.net>
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
