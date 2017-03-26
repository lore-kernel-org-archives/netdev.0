From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH iproute2] man: fix man page warnings
Date: Sun, 26 Mar 2017 21:11:14 +0200
Message-ID: <20170326191114.3756-1-alexander@alemayhu.com>
Cc: stephen@networkplumber.org,
        Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33911 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdCZTMB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Mar 2017 15:12:01 -0400
Received: by mail-lf0-f50.google.com with SMTP id z15so11710156lfd.1
        for <netdev@vger.kernel.org>; Sun, 26 Mar 2017 12:11:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While generating PDFs from the man pages, I saw the warning below from
several files. Compared the tc-matchall.8 with bridge.8 and used .RI
instead of .R. It should have no effect on the man page rendering.

    `R' is a string (producing the registered sign), not a macro.

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 man/man8/tc-flower.8   | 2 +-
 man/man8/tc-ife.8      | 2 +-
 man/man8/tc-matchall.8 | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index fc5bac503324..ba290657c224 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -20,7 +20,7 @@ flower \- flow based traffic control filter
 .B indev
 .IR ifname " | "
 .BR skip_sw " | " skip_hw
-.R " | { "
+.RI " | { "
 .BR dst_mac " | " src_mac " } "
 .IR MASKED_LLADDR " | "
 .B vlan_id
diff --git a/man/man8/tc-ife.8 b/man/man8/tc-ife.8
index dae8b9be9bcb..a8f1f287d150 100644
--- a/man/man8/tc-ife.8
+++ b/man/man8/tc-ife.8
@@ -13,7 +13,7 @@ IFE - encapsulate/decapsulate metadata
 .IR SMAC " ] "
 .RB "[ " type
 .IR TYPE " ] "
-.R "[ "
+.RI "[ "
 .IR CONTROL " ] "
 .RB "[ " index
 .IR INDEX " ] "
diff --git a/man/man8/tc-matchall.8 b/man/man8/tc-matchall.8
index 53b2194e023a..e3cddb1f1ca5 100644
--- a/man/man8/tc-matchall.8
+++ b/man/man8/tc-matchall.8
@@ -7,7 +7,7 @@ matchall \- traffic control filter that matches every packet
 .ti -8
 .BR tc " " filter " ... " matchall " [ "
 .BR skip_sw " | " skip_hw
-.R " ] [ "
+.RI " ] [ "
 .B action
 .IR ACTION_SPEC " ] [ "
 .B classid
-- 
2.9.3
