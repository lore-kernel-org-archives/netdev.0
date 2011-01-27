From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH 1/4] gfs2: Remove 'select SYSFS ...' from Kconfig
Date: Thu, 27 Jan 2011 11:10:27 -0800
Message-ID: <1296155430-3796-2-git-send-email-nab@linux-iscsi.org>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296155430-3796-1-git-send-email-nab@linux-iscsi.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Bellinger <nab@linux-iscsi.org>

With CONFIGFS_FS now doing 'select SYSFS' by default, the extra
'select SYSFS if GFS2_FS_LOCKING_DLM' for GFS2_FS is now unnecessary.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Nicholas A. Bellinger <nab@linux-iscsi.org>
---
 fs/gfs2/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/gfs2/Kconfig b/fs/gfs2/Kconfig
index c465ae0..ff0a8eb 100644
--- a/fs/gfs2/Kconfig
+++ b/fs/gfs2/Kconfig
@@ -3,7 +3,6 @@ config GFS2_FS
 	depends on (64BIT || LBDAF)
 	select DLM if GFS2_FS_LOCKING_DLM
 	select CONFIGFS_FS if GFS2_FS_LOCKING_DLM
-	select SYSFS if GFS2_FS_LOCKING_DLM
 	select IP_SCTP if DLM_SCTP
 	select FS_POSIX_ACL
 	select CRC32
-- 
1.7.3.5
