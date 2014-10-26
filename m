From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] gitignore: Ignore 'doc' files generated at runtime
Date: Sun, 26 Oct 2014 12:18:56 +0200
Message-ID: <1414318736-2575-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:54535 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbaJZK17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 06:27:59 -0400
Received: by mail-lb0-f182.google.com with SMTP id f15so3255359lbj.41
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2014 03:27:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The list is based on doc/Makefile 'clean' target

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 .gitignore | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/.gitignore b/.gitignore
index 5d1e189..98d83c5 100644
--- a/.gitignore
+++ b/.gitignore
@@ -35,3 +35,12 @@ series
 # tests
 testsuite/results
 testsuite/iproute2/iproute2-this
+
+# doc files generated at runtime
+doc/*.aux
+doc/*.log
+doc/*.toc
+doc/*.ps
+doc/*.dvi
+doc/*.html
+doc/*.pdf
-- 
2.1.0
