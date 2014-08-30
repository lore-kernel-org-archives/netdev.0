From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] ip man: Added short description for hsr link type
Date: Sun, 31 Aug 2014 01:57:48 +0300
Message-ID: <1409439468-3300-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:55844 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaH3XFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 19:05:39 -0400
Received: by mail-la0-f51.google.com with SMTP id gl10so4302646lab.24
        for <netdev@vger.kernel.org>; Sat, 30 Aug 2014 16:05:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For hsr link there was no short description in ip-link man page.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 6df0f8f..29d12fb 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -171,6 +171,9 @@ Link types:
 .B dummy
 - Dummy network interface
 .sp
+.B hsr
+- High-availability Seamless Redundancy device
+.sp
 .B ifb
 - Intermediate Functional Block device
 .sp
-- 
2.1.0
