From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH 2/4] net: Make NETCONSOLE_DYNAMIC use select CONFIGFS_FS
Date: Thu, 27 Jan 2011 11:10:28 -0800
Message-ID: <1296155430-3796-3-git-send-email-nab@linux-iscsi.org>
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

Convert 'depends && SYSFS && CONFIGFS_FS' to 'select CONFIGFS_FS'

Reported-by: Joel Becker <jlbec@evilplan.org>
Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Nicholas A. Bellinger <nab@linux-iscsi.org>
---
 drivers/net/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..3d23ebb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3389,7 +3389,8 @@ config NETCONSOLE
 
 config NETCONSOLE_DYNAMIC
 	bool "Dynamic reconfiguration of logging targets"
-	depends on NETCONSOLE && SYSFS && CONFIGFS_FS
+	depends on NETCONSOLE
+	select CONFIGFS_FS
 	help
 	  This option enables the ability to dynamically reconfigure target
 	  parameters (interface, IP addresses, port numbers, MAC addresses)
-- 
1.7.3.5
