From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH 4/4] ocfs2: Make OCFS2_FS use select CONFIGFS_FS
Date: Thu, 27 Jan 2011 11:10:30 -0800
Message-ID: <1296155430-3796-5-git-send-email-nab@linux-iscsi.org>
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
Received: from nm11-vm0.bullet.mail.ne1.yahoo.com ([98.138.90.58]:29361 "HELO
	nm11-vm0.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753381Ab1A0TKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 14:10:43 -0500
In-Reply-To: <1296155430-3796-1-git-send-email-nab@linux-iscsi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Bellinger <nab@linux-iscsi.org>

Convert 'depends && SYSFS && CONFIGFS_FS' to 'select CONFIGFS_FS'

Reported-by: Joel Becker <jlbec@evilplan.org>
Signed-off-by: Nicholas A. Bellinger <nab@linux-iscsi.org>
---
 fs/ocfs2/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/ocfs2/Kconfig b/fs/ocfs2/Kconfig
index 77a8de5..bb03131 100644
--- a/fs/ocfs2/Kconfig
+++ b/fs/ocfs2/Kconfig
@@ -1,6 +1,7 @@
 config OCFS2_FS
 	tristate "OCFS2 file system support"
-	depends on NET && SYSFS && CONFIGFS_FS
+	depends on NET
+	select CONFIGFS_FS
 	select JBD2
 	select CRC32
 	select QUOTA
-- 
1.7.3.5

