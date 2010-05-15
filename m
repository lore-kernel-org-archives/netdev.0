From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/3] cxgb4i_v3: add build support
Date: Sat, 15 May 2010 22:45:50 +0530
Message-ID: <1273943752-32486-2-git-send-email-rakesh@chelsio.com>
References: <1273943752-32486-1-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>, Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        Rakesh Ranjan <rranjan-UJ4WrezqVcvwEYdC/TKypOqkaFVsf6Qi@public.gmane.org>
To: NETDEVML <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, SCSIDEVML <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        OISCSIML <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <open-iscsi+bncCKnrzee6GxCQrrvfBBoEs07lUg-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1273943752-32486-1-git-send-email-rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>,
	<mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Rakesh Ranjan <rranjan-UJ4WrezqVcvwEYdC/TKypOqkaFVsf6Qi@public.gmane.org>


Signed-off-by: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/scsi/Kconfig        |    1 +
 drivers/scsi/Makefile       |    1 +
 drivers/scsi/cxgb4i/Kbuild  |    4 ++++
 drivers/scsi/cxgb4i/Kconfig |    7 +++++++
 4 files changed, 13 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/cxgb4i/Kbuild
 create mode 100644 drivers/scsi/cxgb4i/Kconfig

diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index 75f2336..fc3810a 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -371,6 +371,7 @@ config ISCSI_TCP
 	 http://open-iscsi.org
 
 source "drivers/scsi/cxgb3i/Kconfig"
+source "drivers/scsi/cxgb4i/Kconfig"
 source "drivers/scsi/bnx2i/Kconfig"
 source "drivers/scsi/be2iscsi/Kconfig"
 
diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
index 1c7ac49..46dcdc8 100644
--- a/drivers/scsi/Makefile
+++ b/drivers/scsi/Makefile
@@ -133,6 +133,7 @@ obj-$(CONFIG_SCSI_STEX)		+= stex.o
 obj-$(CONFIG_SCSI_MVSAS)	+= mvsas/
 obj-$(CONFIG_PS3_ROM)		+= ps3rom.o
 obj-$(CONFIG_SCSI_CXGB3_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgb3i/
+obj-$(CONFIG_SCSI_CXGB4_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgb4i/
 obj-$(CONFIG_SCSI_BNX2_ISCSI)	+= libiscsi.o bnx2i/
 obj-$(CONFIG_BE2ISCSI)		+= libiscsi.o be2iscsi/
 obj-$(CONFIG_SCSI_PMCRAID)	+= pmcraid.o
diff --git a/drivers/scsi/cxgb4i/Kbuild b/drivers/scsi/cxgb4i/Kbuild
new file mode 100644
index 0000000..1cb87b9
--- /dev/null
+++ b/drivers/scsi/cxgb4i/Kbuild
@@ -0,0 +1,4 @@
+EXTRA_CFLAGS += -I$(srctree)/drivers/net/cxgb4
+
+cxgb4i-y := libcxgbi.o cxgb4i_snic.o cxgb4i_iscsi.o cxgb4i_offload.o cxgb4i_ddp.o
+obj-$(CONFIG_SCSI_CXGB4_ISCSI) += cxgb4i.o
diff --git a/drivers/scsi/cxgb4i/Kconfig b/drivers/scsi/cxgb4i/Kconfig
new file mode 100644
index 0000000..3f33dc2
--- /dev/null
+++ b/drivers/scsi/cxgb4i/Kconfig
@@ -0,0 +1,7 @@
+config SCSI_CXGB4_ISCSI
+	tristate "Chelsio T4 iSCSI support"
+	depends on CHELSIO_T4_DEPENDS
+	select CHELSIO_T4
+	select SCSI_ISCSI_ATTRS
+	---help---
+	This driver supports iSCSI offload for the Chelsio T4 series devices.
-- 
1.6.6.1

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
