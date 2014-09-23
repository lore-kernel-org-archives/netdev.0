From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH 4/5] sh: Set CONFIG_NET=y in defconfigs
Date: Tue, 23 Sep 2014 17:44:03 +0200
Message-ID: <1411487044-14071-4-git-send-email-mmarek@suse.cz>
References: <54218AEF.5090200@suse.cz>
 <1411487044-14071-1-git-send-email-mmarek@suse.cz>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-kbuild@vger.kernel.org,
	linux-sh@vger.kernel.org
To: sfr@canb.auug.org.au, rdunlap@infradead.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411487044-14071-1-git-send-email-mmarek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 5d6be6a5 ("scsi_netlink : Make SCSI_NETLINK dependent on NET
instead of selecting NET") removed what happened to be the only instance
of 'select NET'. Defconfigs that were relying on the select now lack
networking support.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-sh@vger.kernel.org
Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 arch/sh/configs/sdk7780_defconfig | 1 +
 arch/sh/configs/sh2007_defconfig  | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/sh/configs/sdk7780_defconfig b/arch/sh/configs/sdk7780_defconfig
index 6a96b9a..bbd4c22 100644
--- a/arch/sh/configs/sdk7780_defconfig
+++ b/arch/sh/configs/sdk7780_defconfig
@@ -30,6 +30,7 @@ CONFIG_PCI_DEBUG=y
 CONFIG_PCCARD=y
 CONFIG_YENTA=y
 CONFIG_HOTPLUG_PCI=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_INET=y
diff --git a/arch/sh/configs/sh2007_defconfig b/arch/sh/configs/sh2007_defconfig
index e741b1e..df25ae7 100644
--- a/arch/sh/configs/sh2007_defconfig
+++ b/arch/sh/configs/sh2007_defconfig
@@ -25,6 +25,7 @@ CONFIG_CMDLINE_OVERWRITE=y
 CONFIG_CMDLINE="console=ttySC1,115200 ip=dhcp root=/dev/nfs rw nfsroot=/nfs/rootfs,rsize=1024,wsize=1024 earlyprintk=sh-sci.1"
 CONFIG_PCCARD=y
 CONFIG_BINFMT_MISC=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_XFRM_USER=y
-- 
1.8.4.5
