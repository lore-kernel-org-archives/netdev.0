From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] configure: Add search path for 64bit library.
Date: Tue, 7 Aug 2012 12:22:56 +0800
Message-ID: <1344313376-22602-1-git-send-email-lw@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Li Wei <lw@cn.fujitsu.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:16581 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab2HGEXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 00:23:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 configure |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure b/configure
index 0f4444f..997759c 100755
--- a/configure
+++ b/configure
@@ -149,7 +149,7 @@ check_ipt()
 check_ipt_lib_dir()
 {
 	IPT_LIB_DIR=""
-	for dir in /lib /usr/lib /usr/local/lib
+	for dir in /lib /usr/lib /usr/local/lib /lib64 /usr/lib64 /usr/local/lib64
 	do
 		for file in $dir/{xtables,iptables}/lib*t_*so ; do
 			if [ -f $file ]; then
-- 
1.7.10.1
