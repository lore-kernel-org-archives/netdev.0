From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 2/2] testsuite: search for kernel config in /boot
Date: Wed, 15 Feb 2017 21:26:42 +0000
Message-ID: <20170215212642.10131-2-asbjorn@asbjorn.st>
References: <20170215212642.10131-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:46254 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751732AbdBOVfW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:35:22 -0500
In-Reply-To: <20170215212642.10131-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for finding the kernel config in Debian
and derivatives.

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 testsuite/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/testsuite/Makefile b/testsuite/Makefile
index fc693368..055136b5 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -17,7 +17,7 @@ ifneq (,$(wildcard /proc/config.gz))
 	KENV := $(shell cat /proc/config.gz | gunzip | grep ^CONFIG)
 else
 KVER := $(shell uname -r)
-KCPATHS := /lib/modules/$(KVER)/config
+KCPATHS := /lib/modules/$(KVER)/config /boot/config-$(KVER)
 KCPATH := $(firstword $(wildcard $(KCPATHS)))
 ifneq (,$(KCPATH))
 	KENV := $(shell cat ${KCPATH} | grep ^CONFIG)
-- 
2.11.0
