From: junwei.zhang@6wind.com
Subject: [PATCH 1/2] kernel: remove unnecessary head file
Date: Fri, 14 Jun 2013 15:29:53 +0800
Message-ID: <1371194994-6130-1-git-send-email-junwei.zhang@6wind.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, JunweiZhang <junwei.zhang@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:64136 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab3FNH1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 03:27:55 -0400
Received: by mail-pd0-f173.google.com with SMTP id v14so304198pde.32
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 00:27:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: JunweiZhang <junwei.zhang@6wind.com>

ip_vs.h is not necessary for sysctl_binary.c.

prepare for the next patch to avoid compile issue.

Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 kernel/sysctl_binary.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index aea4a9e..b609213 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -3,7 +3,6 @@
 #include "../fs/xfs/xfs_sysctl.h"
 #include <linux/sunrpc/debug.h>
 #include <linux/string.h>
-#include <net/ip_vs.h>
 #include <linux/syscalls.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
-- 
1.8.1.2
