From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH 3/4] dlm: Make DLM use select CONFIGFS_FS
Date: Thu, 27 Jan 2011 11:10:29 -0800
Message-ID: <1296155430-3796-4-git-send-email-nab@linux-iscsi.org>
References: <1296155430-3796-1-git-send-email-nab@linux-iscsi.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, Joel Becker <jlbec@evilplan.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Americo Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm10.bullet.mail.ne1.yahoo.com ([98.138.90.73]:24752 "HELO
	nm10.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753383Ab1A0TKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 14:10:39 -0500
In-Reply-To: <1296155430-3796-1-git-send-email-nab@linux-iscsi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Bellinger <nab@linux-iscsi.org>

Convert 'depends && SYSFS && CONFIGFS_FS' to 'select CONFIGFS_FS'

Reported-by: Joel Becker <jlbec@evilplan.org>
Signed-off-by: Nicholas A. Bellinger <nab@linux-iscsi.org>
---
 fs/dlm/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dlm/Kconfig b/fs/dlm/Kconfig
index 1897eb1..4f65a50 100644
--- a/fs/dlm/Kconfig
+++ b/fs/dlm/Kconfig
@@ -1,7 +1,7 @@
 menuconfig DLM
 	tristate "Distributed Lock Manager (DLM)"
-	depends on EXPERIMENTAL && INET
-	depends on SYSFS && CONFIGFS_FS && (IPV6 || IPV6=n)
+	depends on EXPERIMENTAL && INET && (IPV6 || IPV6=n)
+	select CONFIGFS_FS
 	select IP_SCTP
 	help
 	A general purpose distributed lock manager for kernel or userspace
-- 
1.7.3.5

