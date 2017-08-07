From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 2/5] inet: include net/sock.h in inet_common.h
Date: Mon,  7 Aug 2017 10:28:15 -0700
Message-ID: <20170807172818.31855-3-tom@quantonium.net>
References: <20170807172818.31855-1-tom@quantonium.net>
Cc: rohit@quantonium.net, davejwatson@fb.com, john.fastabend@gmail.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34975 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdHGR24 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:28:56 -0400
Received: by mail-pf0-f174.google.com with SMTP id t86so4098417pfe.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 10:28:56 -0700 (PDT)
In-Reply-To: <20170807172818.31855-1-tom@quantonium.net>
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
