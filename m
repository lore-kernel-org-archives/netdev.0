From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: fix Makefile to build skbmod
Date: Fri, 19 May 2017 13:05:43 -0400
Message-ID: <1495213543-30318-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33849 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753424AbdESRGJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 13:06:09 -0400
Received: by mail-io0-f196.google.com with SMTP id 12so7955702iol.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:06:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 tc/Makefile | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/Makefile b/tc/Makefile
index 9a6bb1d..678b302 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -45,6 +45,7 @@ TCMODULES += m_nat.o
 TCMODULES += m_pedit.o
 TCMODULES += m_ife.o
 TCMODULES += m_skbedit.o
+TCMODULES += m_skbmod.o
 TCMODULES += m_csum.o
 TCMODULES += m_simple.o
 TCMODULES += m_vlan.o
-- 
1.9.1
