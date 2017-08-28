From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH iproute2 4/4] man: tc-ife: add default type note
Date: Mon, 28 Aug 2017 15:07:38 -0400
Message-ID: <20170828190738.26829-5-aring@mojatatu.com>
References: <20170828190738.26829-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33859 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdH1TIu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:08:50 -0400
Received: by mail-io0-f196.google.com with SMTP id d81so382697ioj.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:08:50 -0700 (PDT)
In-Reply-To: <20170828190738.26829-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tc-ife man page that the default IFE ethertype
will be used if it's not specified.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 man/man8/tc-ife.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/tc-ife.8 b/man/man8/tc-ife.8
index 3a42d51b..fd2df6c3 100644
--- a/man/man8/tc-ife.8
+++ b/man/man8/tc-ife.8
@@ -82,7 +82,7 @@ is required only when
 Optional six byte destination or source MAC address to encode.
 .TP
 .BI type " TYPE"
-Optional 16-bit ethertype to encode.
+Optional 16-bit ethertype to encode. If not specified value of 0xED3E will be used.
 .TP
 .BI CONTROL
 Action to take following an encode/decode.
-- 
2.11.0
