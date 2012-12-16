From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 3/3] configure: pull AR from the env too
Date: Sun, 16 Dec 2012 17:09:17 -0500
Message-ID: <1355695757-9957-3-git-send-email-vapier@gentoo.org>
References: <1355695757-9957-1-git-send-email-vapier@gentoo.org>
Cc: jengelh@inai.de
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58784 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365Ab2LPWJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 17:09:19 -0500
In-Reply-To: <1355695757-9957-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This matches the existing CC behavior.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 configure | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/configure b/configure
index ea1038d..7c2db9b 100755
--- a/configure
+++ b/configure
@@ -10,7 +10,9 @@ trap 'status=$?; rm -rf $TMPDIR; exit $status' EXIT HUP INT QUIT TERM
 check_toolchain()
 {
 : ${PKG_CONFIG:=pkg-config}
+: ${AR=ar}
 : ${CC=gcc}
+echo "AR:=${AR}" >>Config
 echo "CC:=${CC}" >>Config
 echo "PKG_CONFIG:=${PKG_CONFIG}" >>Config
 }
-- 
1.8.0
