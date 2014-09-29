From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Add runtime generated files to .gitignore
Date: Mon, 29 Sep 2014 23:35:38 +0300
Message-ID: <1412022938-27969-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:53763 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbaI2UoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:44:09 -0400
Received: by mail-la0-f44.google.com with SMTP id gi9so8578338lab.31
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 13:44:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When make tests then 2 folders are generated:

    testsuite/results
    testsuite/iproute2/iproute2-this

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 .gitignore | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/.gitignore b/.gitignore
index 3ba2632..5d1e189 100644
--- a/.gitignore
+++ b/.gitignore
@@ -31,3 +31,7 @@ series
 .gdbinit
 .gdb_history
 *.gdb
+
+# tests
+testsuite/results
+testsuite/iproute2/iproute2-this
-- 
2.1.0
