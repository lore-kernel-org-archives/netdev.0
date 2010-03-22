From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] netconsole: do not depend on experimental
Date: Mon, 22 Mar 2010 05:59:23 -0400
Message-ID: <20100322100305.5518.29500.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Nowadays, most distributions enable netconsole by default,
including RHEL, Fedora, Debian, Arch, Opensuse. And
we don't have any bug reports about it. So I think there
is no need to mark it as experimental any more.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: WANG Cong <amwang@redhat.com>

---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0ba5b8e..e3d6c52 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3252,15 +3252,14 @@ config NET_FC
 	  "SCSI generic support".
 
 config NETCONSOLE
-	tristate "Network console logging support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	tristate "Network console logging support"
 	---help---
 	If you want to log kernel messages over the network, enable this.
 	See <file:Documentation/networking/netconsole.txt> for details.
 
 config NETCONSOLE_DYNAMIC
-	bool "Dynamic reconfiguration of logging targets (EXPERIMENTAL)"
-	depends on NETCONSOLE && SYSFS && EXPERIMENTAL
+	bool "Dynamic reconfiguration of logging targets"
+	depends on NETCONSOLE && SYSFS
 	select CONFIGFS_FS
 	help
 	  This option enables the ability to dynamically reconfigure target
