From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][2.4] more atm changes backported to 2.4
Date: Thu, 10 Jul 2003 16:31:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307102033.h6AKXtsG006493@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[atm]: make atm buildable as a module

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1013  -> 1.1014 
#	 net/sched/Config.in	1.3     -> 1.4    
#	 arch/cris/config.in	1.13    -> 1.13.1.1
#	drivers/net/Config.in	1.62    -> 1.63   
#	arch/sparc/config.in	1.14    -> 1.14.1.1
#	    net/atm/Makefile	1.5     -> 1.6    
#	       net/Config.in	1.11    -> 1.12   
#	arch/alpha/config.in	1.22.1.1 -> 1.22.1.2
#	arch/ppc64/config.in	1.6     -> 1.6.1.1
#	      net/atm/proc.c	1.7     -> 1.8    
#	       net/atm/pvc.c	1.3     -> 1.4    
#	arch/sparc64/config.in	1.25    -> 1.25.1.1
#	 arch/i386/config.in	1.42    -> 1.42.1.1
#	 include/linux/net.h	1.2     -> 1.3    
#	       net/netsyms.c	1.36    -> 1.37   
#	   arch/sh/config.in	1.8     -> 1.8.1.1
#	 arch/ia64/config.in	1.17    -> 1.17.1.1
#	  arch/ppc/config.in	1.36    -> 1.36.1.1
#	       net/atm/svc.c	1.3     -> 1.4    
#	arch/x86_64/config.in	1.4     -> 1.4.1.1
#	    net/atm/common.h	1.1     -> 1.2    
#	drivers/atm/Config.in	1.7     -> 1.8    
#	arch/parisc/config.in	1.5     -> 1.5.1.1
#	    net/atm/common.c	1.16    -> 1.17   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/27	chas@relax.cmf.nrl.navy.mil	1.1014
# make atm buildable as a module
# --------------------------------------------
#
diff -Nru a/arch/alpha/config.in b/arch/alpha/config.in
--- a/arch/alpha/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/alpha/config.in	Mon Jun 30 13:22:50 2003
@@ -367,7 +367,7 @@
   bool 'Network device support' CONFIG_NETDEVICES
   if [ "$CONFIG_NETDEVICES" = "y" ]; then
     source drivers/net/Config.in
-    if [ "$CONFIG_ATM" = "y" ]; then
+    if [ "$CONFIG_ATM" != "n" ]; then
       source drivers/atm/Config.in
     fi
   fi
diff -Nru a/arch/cris/config.in b/arch/cris/config.in
--- a/arch/cris/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/cris/config.in	Mon Jun 30 13:22:50 2003
@@ -199,7 +199,7 @@
   bool 'Network device support' CONFIG_NETDEVICES
   if [ "$CONFIG_NETDEVICES" = "y" ]; then
     source drivers/net/Config.in
-      if [ "$CONFIG_ATM" = "y" ]; then
+      if [ "$CONFIG_ATM" != "n" ]; then
          source drivers/atm/Config.in
       fi
   fi
diff -Nru a/arch/i386/config.in b/arch/i386/config.in
--- a/arch/i386/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/i386/config.in	Mon Jun 30 13:22:50 2003
@@ -393,7 +393,7 @@
    bool 'Network device support' CONFIG_NETDEVICES
    if [ "$CONFIG_NETDEVICES" = "y" ]; then
       source drivers/net/Config.in
-      if [ "$CONFIG_ATM" = "y" ]; then
+      if [ "$CONFIG_ATM" != "n" ]; then
          source drivers/atm/Config.in
       fi
    fi
diff -Nru a/arch/ia64/config.in b/arch/ia64/config.in
--- a/arch/ia64/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/ia64/config.in	Mon Jun 30 13:22:50 2003
@@ -179,7 +179,7 @@
     bool 'Network device support' CONFIG_NETDEVICES
     if [ "$CONFIG_NETDEVICES" = "y" ]; then
       source drivers/net/Config.in
-      if [ "$CONFIG_ATM" = "y" ]; then
+      if [ "$CONFIG_ATM" != "n" ]; then
          source drivers/atm/Config.in
       fi
     fi
diff -Nru a/arch/parisc/config.in b/arch/parisc/config.in
--- a/arch/parisc/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/parisc/config.in	Mon Jun 30 13:22:50 2003
@@ -136,7 +136,7 @@
 
    if [ "$CONFIG_NETDEVICES" = "y" ]; then
       source drivers/net/Config.in
-      if [ "$CONFIG_ATM" = "y" ]; then
+      if [ "$CONFIG_ATM" != "n" ]; then
          source drivers/atm/Config.in
       fi
    fi
diff -Nru a/arch/ppc/config.in b/arch/ppc/config.in
--- a/arch/ppc/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/ppc/config.in	Mon Jun 30 13:22:50 2003
@@ -324,7 +324,7 @@
   bool 'Network device support' CONFIG_NETDEVICES
   if [ "$CONFIG_NETDEVICES" = "y" ]; then
     source drivers/net/Config.in
-    if [ "$CONFIG_ATM" = "y" ]; then
+    if [ "$CONFIG_ATM" != "n" ]; then
       source drivers/atm/Config.in
     fi
   fi
diff -Nru a/arch/ppc64/config.in b/arch/ppc64/config.in
--- a/arch/ppc64/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/ppc64/config.in	Mon Jun 30 13:22:50 2003
@@ -141,7 +141,7 @@
    bool 'Network device support' CONFIG_NETDEVICES
    if [ "$CONFIG_NETDEVICES" = "y" ]; then
       source drivers/net/Config.in
-      if [ "$CONFIG_ATM" = "y" ]; then
+      if [ "$CONFIG_ATM" != "n" ]; then
          source drivers/atm/Config.in
       fi
    fi
diff -Nru a/arch/sh/config.in b/arch/sh/config.in
--- a/arch/sh/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/sh/config.in	Mon Jun 30 13:22:50 2003
@@ -259,7 +259,7 @@
    bool 'Network device support' CONFIG_NETDEVICES
    if [ "$CONFIG_NETDEVICES" = "y" ]; then
       source drivers/net/Config.in
-      if [ "$CONFIG_ATM" = "y" ]; then
+      if [ "$CONFIG_ATM" != "n" ]; then
          source drivers/atm/Config.in
       fi
    fi
diff -Nru a/arch/sparc/config.in b/arch/sparc/config.in
--- a/arch/sparc/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/sparc/config.in	Mon Jun 30 13:22:50 2003
@@ -209,7 +209,7 @@
         dep_tristate '  PPP BSD-Compress compression' CONFIG_PPP_BSDCOMP m
 	if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
 	  dep_tristate '  PPP over Ethernet (EXPERIMENTAL)' CONFIG_PPPOE $CONFIG_PPP
-	  if [ "$CONFIG_ATM" = "y" ]; then
+	  if [ "$CONFIG_ATM" != "n" ]; then
 	    dep_tristate '  PPP over ATM (EXPERIMENTAL)' CONFIG_PPPOATM $CONFIG_PPP
 	  fi
 	fi
@@ -235,7 +235,7 @@
 #      if [ "$CONFIG_FDDI" = "y" ]; then
 #      fi
 
-      if [ "$CONFIG_ATM" = "y" ]; then
+      if [ "$CONFIG_ATM" != "n" ]; then
 	 source drivers/atm/Config.in
       fi
    fi
diff -Nru a/arch/sparc64/config.in b/arch/sparc64/config.in
--- a/arch/sparc64/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/sparc64/config.in	Mon Jun 30 13:22:50 2003
@@ -234,7 +234,7 @@
    bool 'Network device support' CONFIG_NETDEVICES
    if [ "$CONFIG_NETDEVICES" = "y" ]; then
       source drivers/net/Config.in
-      if [ "$CONFIG_ATM" = "y" ]; then
+      if [ "$CONFIG_ATM" != "n" ]; then
 	source drivers/atm/Config.in
       fi
    fi
diff -Nru a/arch/x86_64/config.in b/arch/x86_64/config.in
--- a/arch/x86_64/config.in	Mon Jun 30 13:22:50 2003
+++ b/arch/x86_64/config.in	Mon Jun 30 13:22:50 2003
@@ -173,7 +173,7 @@
    if [ "$CONFIG_NETDEVICES" = "y" ]; then
       source drivers/net/Config.in
 # seems to be largely not 64bit safe	   
-#      if [ "$CONFIG_ATM" = "y" ]; then
+#      if [ "$CONFIG_ATM" != "n" ]; then
 #         source drivers/atm/Config.in
 #      fi
    fi
diff -Nru a/drivers/atm/Config.in b/drivers/atm/Config.in
--- a/drivers/atm/Config.in	Mon Jun 30 13:22:50 2003
+++ b/drivers/atm/Config.in	Mon Jun 30 13:22:50 2003
@@ -4,11 +4,11 @@
 mainmenu_option next_comment
 comment 'ATM drivers'
 if [ "$CONFIG_INET" = "y" ]; then
-   tristate 'ATM over TCP' CONFIG_ATM_TCP
+   dep_tristate 'ATM over TCP' CONFIG_ATM_TCP $CONFIG_ATM
 fi
 if [ "$CONFIG_PCI" = "y" ]; then
-   tristate 'Efficient Networks Speedstream 3010' CONFIG_ATM_LANAI
-   tristate 'Efficient Networks ENI155P' CONFIG_ATM_ENI
+   dep_tristate 'Efficient Networks Speedstream 3010' CONFIG_ATM_LANAI $CONFIG_ATM
+   dep_tristate 'Efficient Networks ENI155P' CONFIG_ATM_ENI $CONFIG_ATM
    if [ "$CONFIG_ATM_ENI" != "n" ]; then
       bool '  Enable extended debugging' CONFIG_ATM_ENI_DEBUG
       bool '  Fine-tune burst settings' CONFIG_ATM_ENI_TUNE_BURST
@@ -23,8 +23,8 @@
 	 bool '    Enable 2W RX bursts (optional)' CONFIG_ATM_ENI_BURST_RX_2W
       fi
    fi
-   tristate 'Fujitsu FireStream (FS50/FS155) ' CONFIG_ATM_FIRESTREAM
-   tristate 'ZeitNet ZN1221/ZN1225' CONFIG_ATM_ZATM
+   dep_tristate 'Fujitsu FireStream (FS50/FS155) ' CONFIG_ATM_FIRESTREAM $CONFIG_ATM
+   dep_tristate 'ZeitNet ZN1221/ZN1225' CONFIG_ATM_ZATM $CONFIG_ATM
    if [ "$CONFIG_ATM_ZATM" != "n" ]; then
       bool '  Enable extended debugging' CONFIG_ATM_ZATM_DEBUG
       if [ "$CONFIG_X86" = "y" ]; then
@@ -35,32 +35,32 @@
 #   if [ "$CONFIG_ATM_TNETA1570" = "y" ]; then
 #      bool '  Enable extended debugging' CONFIG_ATM_TNETA1570_DEBUG n
 #   fi
-   tristate 'IDT 77201 (NICStAR) (ForeRunnerLE)' CONFIG_ATM_NICSTAR
+   dep_tristate 'IDT 77201 (NICStAR) (ForeRunnerLE)' CONFIG_ATM_NICSTAR $CONFIG_ATM
    if [ "$CONFIG_ATM_NICSTAR" != "n" ]; then
       bool '  Use suni PHY driver (155Mbps)' CONFIG_ATM_NICSTAR_USE_SUNI
       bool '  Use IDT77015 PHY driver (25Mbps)' CONFIG_ATM_NICSTAR_USE_IDT77105
    fi
-   tristate 'IDT 77252 (NICStAR II)' CONFIG_ATM_IDT77252
+   dep_tristate 'IDT 77252 (NICStAR II)' CONFIG_ATM_IDT77252 $CONFIG_ATM
    if [ "$CONFIG_ATM_IDT77252" != "n" ]; then
       bool '  Enable debugging messages' CONFIG_ATM_IDT77252_DEBUG
       bool '  Receive ALL cells in raw queue' CONFIG_ATM_IDT77252_RCV_ALL
       define_bool CONFIG_ATM_IDT77252_USE_SUNI y
    fi
-   tristate 'Madge Ambassador (Collage PCI 155 Server)' CONFIG_ATM_AMBASSADOR
+   dep_tristate 'Madge Ambassador (Collage PCI 155 Server)' CONFIG_ATM_AMBASSADOR $CONFIG_ATM
    if [ "$CONFIG_ATM_AMBASSADOR" != "n" ]; then
       bool '  Enable debugging messages' CONFIG_ATM_AMBASSADOR_DEBUG
    fi
-   tristate 'Madge Horizon [Ultra] (Collage PCI 25 and Collage PCI 155 Client)' CONFIG_ATM_HORIZON
+   dep_tristate 'Madge Horizon [Ultra] (Collage PCI 25 and Collage PCI 155 Client)' CONFIG_ATM_HORIZON $CONFIG_ATM
    if [ "$CONFIG_ATM_HORIZON" != "n" ]; then
       bool '  Enable debugging messages' CONFIG_ATM_HORIZON_DEBUG
    fi
-    tristate 'Interphase ATM PCI x575/x525/x531' CONFIG_ATM_IA
-    if [ "$CONFIG_ATM_IA" != "n" ]; then
-      bool '  Enable debugging messages' CONFIG_ATM_IA_DEBUG
-    fi
+   dep_tristate 'Interphase ATM PCI x575/x525/x531' CONFIG_ATM_IA $CONFIG_ATM
+   if [ "$CONFIG_ATM_IA" != "n" ]; then
+     bool '  Enable debugging messages' CONFIG_ATM_IA_DEBUG
+   fi
 fi
 if [ "$CONFIG_PCI" = "y" -o "$CONFIG_SBUS" = "y" ]; then
-  tristate 'FORE Systems 200E-series' CONFIG_ATM_FORE200E_MAYBE
+  dep_tristate 'FORE Systems 200E-series' CONFIG_ATM_FORE200E_MAYBE $CONFIG_ATM
   if [ "$CONFIG_ATM_FORE200E_MAYBE" != "n" ]; then
     if [ "$CONFIG_PCI" = "y" ]; then
       bool '  PCA-200E support' CONFIG_ATM_FORE200E_PCA
@@ -93,7 +93,7 @@
   fi
 fi
 if [ "$CONFIG_PCI" = "y" ]; then
-  tristate 'ForeRunner HE Series' CONFIG_ATM_HE
+  dep_tristate 'ForeRunner HE Series' CONFIG_ATM_HE $CONFIG_ATM
   if [ "$CONFIG_ATM_HE" != "n" ]; then
     bool 'Use S/UNI PHY driver' CONFIG_ATM_HE_USE_SUNI
   fi
diff -Nru a/drivers/net/Config.in b/drivers/net/Config.in
--- a/drivers/net/Config.in	Mon Jun 30 13:22:50 2003
+++ b/drivers/net/Config.in	Mon Jun 30 13:22:50 2003
@@ -308,7 +308,7 @@
       dep_tristate '  PPP over Ethernet (EXPERIMENTAL)' CONFIG_PPPOE $CONFIG_PPP
    fi
    if [ ! "$CONFIG_ATM" = "n" ]; then
-      dep_tristate '  PPP over ATM (EXPERIMENTAL)' CONFIG_PPPOATM $CONFIG_PPP $CONFIG_EXPERIMENTAL
+      dep_tristate '  PPP over ATM (EXPERIMENTAL)' CONFIG_PPPOATM $CONFIG_PPP $CONFIG_EXPERIMENTAL $CONFIG_ATM
    fi
 fi
 
diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Mon Jun 30 13:22:50 2003
+++ b/include/linux/net.h	Mon Jun 30 13:22:50 2003
@@ -139,6 +139,7 @@
 extern int	sock_recvmsg(struct socket *, struct msghdr *m, int len, int flags);
 extern int	sock_readv_writev(int type, struct inode * inode, struct file * file,
 				  const struct iovec * iov, long count, long size);
+extern struct socket *sockfd_lookup(int fd, int *err);
 
 extern int	net_ratelimit(void);
 extern unsigned long net_random(void);
diff -Nru a/net/Config.in b/net/Config.in
--- a/net/Config.in	Mon Jun 30 13:22:50 2003
+++ b/net/Config.in	Mon Jun 30 13:22:50 2003
@@ -31,19 +31,19 @@
    fi
 fi
 if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
-   bool 'Asynchronous Transfer Mode (ATM) (EXPERIMENTAL)' CONFIG_ATM
-   if [ "$CONFIG_ATM" = "y" ]; then
+   tristate 'Asynchronous Transfer Mode (ATM) (EXPERIMENTAL)' CONFIG_ATM
+   if [ "$CONFIG_ATM" != "n" ]; then
       if [ "$CONFIG_INET" = "y" ]; then
-	 tristate '  Classical IP over ATM' CONFIG_ATM_CLIP
+	 dep_tristate '  Classical IP over ATM' CONFIG_ATM_CLIP $CONFIG_ATM
 	 if [ "$CONFIG_ATM_CLIP" != "n" ]; then
 	    bool '    Do NOT send ICMP if no neighbour' CONFIG_ATM_CLIP_NO_ICMP
 	 fi
       fi
-      tristate '  LAN Emulation (LANE) support' CONFIG_ATM_LANE
+      dep_tristate '  LAN Emulation (LANE) support' CONFIG_ATM_LANE $CONFIG_ATM
       if [ "$CONFIG_INET" = "y" -a "$CONFIG_ATM_LANE" != "n" ]; then
 	 tristate '    Multi-Protocol Over ATM (MPOA) support' CONFIG_ATM_MPOA
       fi
-      tristate '  RFC1483/2684 Bridged protocols' CONFIG_ATM_BR2684
+      dep_tristate '  RFC1483/2684 Bridged protocols' CONFIG_ATM_BR2684 $CONFIG_ATM
       if [ "$CONFIG_ATM_BR2684" != "n" ]; then
             bool '    Per-VC IP filter kludge' CONFIG_ATM_BR2684_IPFILTER
       fi
diff -Nru a/net/atm/Makefile b/net/atm/Makefile
--- a/net/atm/Makefile	Mon Jun 30 13:22:50 2003
+++ b/net/atm/Makefile	Mon Jun 30 13:22:50 2003
@@ -14,7 +14,10 @@
 list-multi	:= mpoa.o
 mpoa-objs	:= mpc.o mpoa_caches.o mpoa_proc.o
 
-obj-$(CONFIG_ATM) := addr.o pvc.o signaling.o svc.o common.o atm_misc.o raw.o resources.o
+obj-y		:= addr.o pvc.o signaling.o svc.o common.o atm_misc.o raw.o resources.o
+ifeq ($(CONFIG_ATM),m)
+  obj-m += $(O_TARGET)
+endif
 
 ifneq ($(CONFIG_ATM_CLIP),n)
   NEED_IPCOM = ipcommon.o
@@ -31,13 +34,13 @@
 obj-$(CONFIG_ATM_BR2684) += br2684.o
 
 ifeq ($(CONFIG_NET_SCH_ATM),y)
-NEED_IPCOM = ipcommon.o
+  NEED_IPCOM = ipcommon.o
 endif
 
 obj-y += $(NEED_IPCOM)
 
 ifeq ($(CONFIG_PROC_FS),y)
-obj-y += proc.o
+  obj-y += proc.o
 endif
 
 obj-$(CONFIG_ATM_LANE) += lec.o
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 30 13:22:50 2003
+++ b/net/atm/common.c	Mon Jun 30 13:22:50 2003
@@ -21,6 +21,7 @@
 #include <linux/time.h>		/* struct timeval */
 #include <linux/skbuff.h>
 #include <linux/bitops.h>
+#include <linux/init.h>
 #include <net/sock.h>		/* struct sock */
 
 #include <asm/uaccess.h>
@@ -1217,3 +1218,43 @@
         return;
 }        
 #endif
+
+static int __init atm_init(void)
+{
+	int error;
+
+	if ((error = atmpvc_init()) < 0) {
+		printk(KERN_ERR "atmpvc_init() failed with %d\n", error);
+		goto failure;
+	}
+	if ((error = atmsvc_init()) < 0) {
+		printk(KERN_ERR "atmsvc_init() failed with %d\n", error);
+		goto failure;
+	}
+#ifdef CONFIG_PROC_FS
+        if ((error = atm_proc_init()) < 0) {
+		printk(KERN_ERR "atm_proc_init() failed with %d\n",error);
+		goto failure;
+	}
+#endif
+	return 0;
+
+failure:
+	atmsvc_exit();
+	atmpvc_exit();
+	return error;
+}
+
+static void __exit atm_exit(void)
+{
+#ifdef CONFIG_PROC_FS
+	atm_proc_exit();
+#endif
+	atmsvc_exit();
+	atmpvc_exit();
+}
+
+module_init(atm_init);
+module_exit(atm_exit);
+
+MODULE_LICENSE("GPL");
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jun 30 13:22:50 2003
+++ b/net/atm/common.h	Mon Jun 30 13:22:50 2003
@@ -28,7 +28,12 @@
 void atm_release_vcc_sk(struct sock *sk,int free_sk);
 void atm_shutdown_dev(struct atm_dev *dev);
 
+int atmpvc_init(void);
+void atmpvc_exit(void);
+int atmsvc_init(void);
+void atmsvc_exit(void);
 int atm_proc_init(void);
+void atm_proc_exit(void);
 
 /* SVC */
 
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Mon Jun 30 13:22:50 2003
+++ b/net/atm/proc.c	Mon Jun 30 13:22:50 2003
@@ -632,12 +632,28 @@
     name->proc_fops = &proc_spec_atm_operations; \
     name->owner = THIS_MODULE
 
+static struct proc_dir_entry *devices = NULL, *pvc = NULL,
+		*svc = NULL, *arp = NULL, *lec = NULL, *vc = NULL;
 
-int __init atm_proc_init(void)
+static void atm_proc_cleanup(void)
 {
-	struct proc_dir_entry *devices = NULL,*pvc = NULL,*svc = NULL;
-	struct proc_dir_entry *arp = NULL,*lec = NULL,*vc = NULL;
+	if (devices)
+		remove_proc_entry("devices",atm_proc_root);
+	if (pvc)
+		remove_proc_entry("pvc",atm_proc_root);
+	if (svc)
+		remove_proc_entry("svc",atm_proc_root);
+	if (arp)
+		remove_proc_entry("arp",atm_proc_root);
+	if (lec)
+		remove_proc_entry("lec",atm_proc_root);
+	if (vc)
+		remove_proc_entry("vc",atm_proc_root);
+	remove_proc_entry("net/atm",NULL);
+}
 
+int atm_proc_init(void)
+{
 	atm_proc_root = proc_mkdir("net/atm",NULL);
 	if (!atm_proc_root)
 		return -ENOMEM;
@@ -654,12 +670,11 @@
 	return 0;
 
 cleanup:
-	if (devices) remove_proc_entry("devices",atm_proc_root);
-	if (pvc) remove_proc_entry("pvc",atm_proc_root);
-	if (svc) remove_proc_entry("svc",atm_proc_root);
-	if (arp) remove_proc_entry("arp",atm_proc_root);
-	if (lec) remove_proc_entry("lec",atm_proc_root);
-	if (vc) remove_proc_entry("vc",atm_proc_root);
-	remove_proc_entry("net/atm",NULL);
+	atm_proc_cleanup();
 	return -ENOMEM;
+}
+
+void atm_proc_exit(void)
+{
+	atm_proc_cleanup();
 }
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Mon Jun 30 13:22:50 2003
+++ b/net/atm/pvc.c	Mon Jun 30 13:22:50 2003
@@ -120,20 +120,12 @@
  */
 
 
-static int __init atmpvc_init(void)
+int atmpvc_init(void)
 {
-	int error;
-
-	error = sock_register(&pvc_family_ops);
-	if (error < 0) {
-		printk(KERN_ERR "ATMPVC: can't register (%d)",error);
-		return error;
-	}
-#ifdef CONFIG_PROC_FS
-	error = atm_proc_init();
-	if (error) printk("atm_proc_init fails with %d\n",error);
-#endif
-	return 0;
+	return sock_register(&pvc_family_ops);
 }
 
-module_init(atmpvc_init);
+void atmpvc_exit(void)
+{
+	sock_unregister(PF_ATMPVC);
+}
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Jun 30 13:22:50 2003
+++ b/net/atm/svc.c	Mon Jun 30 13:22:50 2003
@@ -443,13 +443,12 @@
  *	Initialize the ATM SVC protocol family
  */
 
-static int __init atmsvc_init(void)
+int atmsvc_init(void)
 {
-	if (sock_register(&svc_family_ops) < 0) {
-		printk(KERN_ERR "ATMSVC: can't register");
-		return -1;
-	}
-	return 0;
+	return sock_register(&svc_family_ops);
 }
 
-module_init(atmsvc_init);
+void atmsvc_exit(void)
+{
+	sock_unregister(PF_ATMSVC);
+}
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Mon Jun 30 13:22:50 2003
+++ b/net/netsyms.c	Mon Jun 30 13:22:50 2003
@@ -163,6 +163,7 @@
 EXPORT_SYMBOL(put_cmsg);
 EXPORT_SYMBOL(sock_kmalloc);
 EXPORT_SYMBOL(sock_kfree_s);
+EXPORT_SYMBOL(sockfd_lookup);
 
 #ifdef CONFIG_FILTER
 EXPORT_SYMBOL(sk_run_filter);
diff -Nru a/net/sched/Config.in b/net/sched/Config.in
--- a/net/sched/Config.in	Mon Jun 30 13:22:50 2003
+++ b/net/sched/Config.in	Mon Jun 30 13:22:50 2003
@@ -6,8 +6,8 @@
 tristate '  CSZ packet scheduler' CONFIG_NET_SCH_CSZ
 #tristate '  H-PFQ packet scheduler' CONFIG_NET_SCH_HPFQ
 #tristate '  H-FSC packet scheduler' CONFIG_NET_SCH_HFCS
-if [ "$CONFIG_ATM" = "y" ]; then
-   bool '  ATM pseudo-scheduler' CONFIG_NET_SCH_ATM
+if [ "$CONFIG_ATM" != "n" ]; then
+   dep_tristate '  ATM pseudo-scheduler' CONFIG_NET_SCH_ATM $CONFIG_ATM
 fi
 tristate '  The simplest PRIO pseudoscheduler' CONFIG_NET_SCH_PRIO
 tristate '  RED queue' CONFIG_NET_SCH_RED





[atm]: eliminate cli, make function names sane

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1014  -> 1.1015 
#	       net/atm/lec.c	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/27	davem@nuts.ninka.net	1.1011.1.17
# Merge nuts.ninka.net:/home/davem/src/BK/network-2.4
# into nuts.ninka.net:/home/davem/src/BK/net-2.4
# --------------------------------------------
# 03/06/27	hch@lst.de	1.1011.1.18
# [CRYPTO-2.4]: Missing ULL postfixes and statics.
# --------------------------------------------
# 03/06/27	chas@relax.cmf.nrl.navy.mil	1.1015
# elminate cli, make function names sane
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Jun 30 13:22:04 2003
+++ b/net/atm/lec.c	Mon Jun 30 13:22:04 2003
@@ -20,6 +20,7 @@
 #include <net/arp.h>
 #include <net/dst.h>
 #include <linux/proc_fs.h>
+#include <linux/spinlock.h>
 
 /* TokenRing if needed */
 #ifdef CONFIG_TR
@@ -55,6 +56,7 @@
 	unsigned char *addr);
 extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 
+static spinlock_t lec_arp_spinlock = SPIN_LOCK_UNLOCKED;
 
 #define DUMP_PACKETS 0 /* 0 = None,
                         * 1 = 30 first bytes
@@ -1049,15 +1051,15 @@
 #define HASH(ch) (ch & (LEC_ARP_TABLE_SIZE -1))
 
 static __inline__ void 
-lec_arp_lock(struct lec_priv *priv)
+lec_arp_get(struct lec_priv *priv)
 {
-        atomic_inc(&priv->lec_arp_lock_var);
+        atomic_inc(&priv->lec_arp_users);
 }
 
 static __inline__ void 
-lec_arp_unlock(struct lec_priv *priv)
+lec_arp_put(struct lec_priv *priv)
 {
-        atomic_dec(&priv->lec_arp_lock_var);
+        atomic_dec(&priv->lec_arp_users);
 }
 
 /*
@@ -1108,33 +1110,33 @@
  * LANE2: Add to the end of the list to satisfy 8.1.13
  */
 static __inline__ void 
-lec_arp_put(struct lec_arp_table **lec_arp_tables, 
-            struct lec_arp_table *to_put)
+lec_arp_add(struct lec_arp_table **lec_arp_tables, 
+            struct lec_arp_table *to_add)
 {
-        unsigned short place;
         unsigned long flags;
+        unsigned short place;
         struct lec_arp_table *tmp;
 
-        save_flags(flags);
-        cli();
+        spin_lock_irqsave(&lec_arp_spinlock, flags);
 
-        place = HASH(to_put->mac_addr[ETH_ALEN-1]);
+        place = HASH(to_add->mac_addr[ETH_ALEN-1]);
         tmp = lec_arp_tables[place];
-        to_put->next = NULL;
+        to_add->next = NULL;
         if (tmp == NULL)
-                lec_arp_tables[place] = to_put;
+                lec_arp_tables[place] = to_add;
   
         else {  /* add to the end */
                 while (tmp->next)
                         tmp = tmp->next;
-                tmp->next = to_put;
+                tmp->next = to_add;
         }
 
-        restore_flags(flags);
+        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+
         DPRINTK("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
-                0xff&to_put->mac_addr[0], 0xff&to_put->mac_addr[1],
-                0xff&to_put->mac_addr[2], 0xff&to_put->mac_addr[3],
-                0xff&to_put->mac_addr[4], 0xff&to_put->mac_addr[5]);
+                0xff&to_add->mac_addr[0], 0xff&to_add->mac_addr[1],
+                0xff&to_add->mac_addr[2], 0xff&to_add->mac_addr[3],
+                0xff&to_add->mac_addr[4], 0xff&to_add->mac_addr[5]);
 }
 
 /*
@@ -1144,16 +1146,15 @@
 lec_arp_remove(struct lec_arp_table **lec_arp_tables,
                struct lec_arp_table *to_remove)
 {
+        unsigned long flags;
         unsigned short place;
         struct lec_arp_table *tmp;
-        unsigned long flags;
         int remove_vcc=1;
 
-        save_flags(flags);
-        cli();
+        spin_lock_irqsave(&lec_arp_spinlock, flags);
 
         if (!to_remove) {
-                restore_flags(flags);
+                spin_unlock_irqrestore(&lec_arp_spinlock, flags);
                 return -1;
         }
         place = HASH(to_remove->mac_addr[ETH_ALEN-1]);
@@ -1165,7 +1166,7 @@
                         tmp = tmp->next;
                 }
                 if (!tmp) {/* Entry was not found */
-                        restore_flags(flags);
+                        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
                         return -1;
                 }
         }
@@ -1191,7 +1192,9 @@
                         lec_arp_clear_vccs(to_remove);
         }
         skb_queue_purge(&to_remove->tx_wait); /* FIXME: good place for this? */
-        restore_flags(flags);
+
+        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
+
         DPRINTK("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 0xff&to_remove->mac_addr[0], 0xff&to_remove->mac_addr[1],
                 0xff&to_remove->mac_addr[2], 0xff&to_remove->mac_addr[3],
@@ -1376,12 +1379,8 @@
 lec_arp_destroy(struct lec_priv *priv)
 {
         struct lec_arp_table *entry, *next;
-        unsigned long flags;
         int i;
 
-        save_flags(flags);
-        cli();
-
         del_timer(&priv->lec_arp_timer);
         
         /*
@@ -1424,7 +1423,6 @@
         priv->mcast_vcc = NULL;
         memset(priv->lec_arp_tables, 0, 
                sizeof(struct lec_arp_table*)*LEC_ARP_TABLE_SIZE);
-        restore_flags(flags);
 }
 
 
@@ -1441,18 +1439,18 @@
         DPRINTK("LEC_ARP: lec_arp_find :%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
                 mac_addr[0]&0xff, mac_addr[1]&0xff, mac_addr[2]&0xff, 
                 mac_addr[3]&0xff, mac_addr[4]&0xff, mac_addr[5]&0xff);
-        lec_arp_lock(priv);
+        lec_arp_get(priv);
         place = HASH(mac_addr[ETH_ALEN-1]);
   
         to_return = priv->lec_arp_tables[place];
         while(to_return) {
                 if (memcmp(mac_addr, to_return->mac_addr, ETH_ALEN) == 0) {
-                        lec_arp_unlock(priv);
+                        lec_arp_put(priv);
                         return to_return;
                 }
                 to_return = to_return->next;
         }
-        lec_arp_unlock(priv);
+        lec_arp_put(priv);
         return NULL;
 }
 
@@ -1579,11 +1577,11 @@
         del_timer(&priv->lec_arp_timer);
 
         DPRINTK("lec_arp_check_expire %p,%d\n",priv,
-                priv->lec_arp_lock_var.counter);
+                atomic_read(&priv->lec_arp_users));
         DPRINTK("expire: eo:%p nf:%p\n",priv->lec_arp_empty_ones,
                 priv->lec_no_forward);
-        if (!priv->lec_arp_lock_var.counter) {
-                lec_arp_lock(priv);
+        if (!atomic_read(&priv->lec_arp_users)) {
+                lec_arp_get(priv);
                 now = jiffies;
                 for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
                         for(entry = lec_arp_tables[i];entry != NULL;) {
@@ -1629,7 +1627,7 @@
                                 }
                         }
                 }
-                lec_arp_unlock(priv);
+                lec_arp_put(priv);
         }
         priv->lec_arp_timer.expires = jiffies + LEC_ARP_REFRESH_INTERVAL;
         add_timer(&priv->lec_arp_timer);
@@ -1691,7 +1689,7 @@
                 if (!entry) {
                         return priv->mcast_vcc;
                 }
-                lec_arp_put(priv->lec_arp_tables, entry);
+                lec_arp_add(priv->lec_arp_tables, entry);
                 /* We want arp-request(s) to be sent */
                 entry->packets_flooded =1;
                 entry->status = ESI_ARP_PENDING;
@@ -1716,7 +1714,7 @@
         struct lec_arp_table *entry, *next;
         int i;
 
-        lec_arp_lock(priv);
+        lec_arp_get(priv);
         DPRINTK("lec_addr_delete\n");
         for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
                 for(entry=priv->lec_arp_tables[i];entry != NULL; entry=next) {
@@ -1727,11 +1725,11 @@
                                 lec_arp_remove(priv->lec_arp_tables, entry);
                                 kfree(entry);
                         }
-                        lec_arp_unlock(priv);
+                        lec_arp_put(priv);
                         return 0;
                 }
         }
-        lec_arp_unlock(priv);
+        lec_arp_put(priv);
         return -1;
 }
 
@@ -1756,7 +1754,7 @@
                 return;   /* LANE2: ignore targetless LE_ARPs for which
                            * we have no entry in the cache. 7.1.30
                            */
-        lec_arp_lock(priv);
+        lec_arp_get(priv);
         if (priv->lec_arp_empty_ones) {
                 entry = priv->lec_arp_empty_ones;
                 if (!memcmp(entry->atm_addr, atm_addr, ATM_ESA_LEN)) {
@@ -1790,13 +1788,13 @@
                                 entry->status = ESI_FORWARD_DIRECT;
                                 memcpy(entry->mac_addr, mac_addr, ETH_ALEN);
                                 entry->last_used = jiffies;
-                                lec_arp_put(priv->lec_arp_tables, entry);
+                                lec_arp_add(priv->lec_arp_tables, entry);
                         }
                         if (remoteflag)
                                 entry->flags|=LEC_REMOTE_FLAG;
                         else
                                 entry->flags&=~LEC_REMOTE_FLAG;
-                        lec_arp_unlock(priv);
+                        lec_arp_put(priv);
                         DPRINTK("After update\n");
                         dump_arp_table(priv);
                         return;
@@ -1806,11 +1804,11 @@
         if (!entry) {
                 entry = make_entry(priv, mac_addr);
                 if (!entry) {
-                        lec_arp_unlock(priv);
+                        lec_arp_put(priv);
                         return;
                 }
                 entry->status = ESI_UNKNOWN;
-                lec_arp_put(priv->lec_arp_tables, entry);
+                lec_arp_add(priv->lec_arp_tables, entry);
                 /* Temporary, changes before end of function */
         }
         memcpy(entry->atm_addr, atm_addr, ATM_ESA_LEN);
@@ -1845,7 +1843,7 @@
         }
         DPRINTK("After update2\n");
         dump_arp_table(priv);
-        lec_arp_unlock(priv);
+        lec_arp_put(priv);
 }
 
 /*
@@ -1859,7 +1857,7 @@
         struct lec_arp_table *entry;
         int i, found_entry=0;
 
-        lec_arp_lock(priv);
+        lec_arp_get(priv);
         if (ioc_data->receive == 2) {
                 /* Vcc for Multicast Forward. No timer, LANEv2 7.1.20 and 2.3.5.3 */
 
@@ -1868,7 +1866,7 @@
                 entry = lec_arp_find(priv, bus_mac);
                 if (!entry) {
                         printk("LEC_ARP: Multicast entry not found!\n");
-                        lec_arp_unlock(priv);
+                        lec_arp_put(priv);
                         return;
                 }
                 memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
@@ -1877,7 +1875,7 @@
 #endif
                 entry = make_entry(priv, bus_mac);
                 if (entry == NULL) {
-                        lec_arp_unlock(priv);
+                        lec_arp_put(priv);
                         return;
                 }
                 del_timer(&entry->timer);
@@ -1886,7 +1884,7 @@
                 entry->old_recv_push = old_push;
                 entry->next = priv->mcast_fwds;
                 priv->mcast_fwds = entry;
-                lec_arp_unlock(priv);
+                lec_arp_put(priv);
                 return;
         } else if (ioc_data->receive == 1) {
                 /* Vcc which we don't want to make default vcc, attach it
@@ -1904,7 +1902,7 @@
                         ioc_data->atm_addr[18],ioc_data->atm_addr[19]);
                 entry = make_entry(priv, bus_mac);
                 if (entry == NULL) {
-                        lec_arp_unlock(priv);
+                        lec_arp_put(priv);
                         return;
                 }
                 memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
@@ -1917,7 +1915,7 @@
                 add_timer(&entry->timer);
                 entry->next = priv->lec_no_forward;
                 priv->lec_no_forward = entry;
-                lec_arp_unlock(priv);
+                lec_arp_put(priv);
 		dump_arp_table(priv);
                 return;
         }
@@ -1976,7 +1974,7 @@
                 }
         }
         if (found_entry) {
-                lec_arp_unlock(priv);
+                lec_arp_put(priv);
                 DPRINTK("After vcc was added\n");
                 dump_arp_table(priv);
                 return;
@@ -1985,7 +1983,7 @@
            this vcc */
         entry = make_entry(priv, bus_mac);
         if (!entry) {
-                lec_arp_unlock(priv);
+                lec_arp_put(priv);
                 return;
         }
         entry->vcc = vcc;
@@ -1998,7 +1996,7 @@
         entry->timer.expires = jiffies + priv->vcc_timeout_period;
         entry->timer.function = lec_arp_expire_vcc;
         add_timer(&entry->timer);
-        lec_arp_unlock(priv);
+        lec_arp_put(priv);
         DPRINTK("After vcc was added\n");
 	dump_arp_table(priv);
 }
@@ -2044,10 +2042,10 @@
                 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
         struct lec_arp_table *to_add;
   
-        lec_arp_lock(priv);
+        lec_arp_get(priv);
         to_add = make_entry(priv, mac_addr);
         if (!to_add) {
-                lec_arp_unlock(priv);
+                lec_arp_put(priv);
                 return -ENOMEM;
         }
         memcpy(to_add->atm_addr, vcc->remote.sas_addr.prv, ATM_ESA_LEN);
@@ -2057,8 +2055,8 @@
         to_add->old_push = vcc->push;
         vcc->push = lec_push;
         priv->mcast_vcc = vcc;
-        lec_arp_put(priv->lec_arp_tables, to_add);
-        lec_arp_unlock(priv);
+        lec_arp_add(priv->lec_arp_tables, to_add);
+        lec_arp_put(priv);
         return 0;
 }
 
@@ -2070,7 +2068,7 @@
 
         DPRINTK("LEC_ARP: lec_vcc_close vpi:%d vci:%d\n",vcc->vpi,vcc->vci);
         dump_arp_table(priv);
-        lec_arp_lock(priv);
+        lec_arp_get(priv);
         for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
                 for(entry = priv->lec_arp_tables[i];entry; entry=next) {
                         next = entry->next;
@@ -2132,7 +2130,7 @@
                 entry = next;
         }
 
-        lec_arp_unlock(priv);
+        lec_arp_put(priv);
 	dump_arp_table(priv);
 }
 
@@ -2140,9 +2138,9 @@
 lec_arp_check_empties(struct lec_priv *priv,
                       struct atm_vcc *vcc, struct sk_buff *skb)
 {
+        unsigned long flags;
         struct lec_arp_table *entry, *prev;
         struct lecdatahdr_8023 *hdr = (struct lecdatahdr_8023 *)skb->data;
-        unsigned long flags;
         unsigned char *src;
 #ifdef CONFIG_TR
         struct lecdatahdr_8025 *tr_hdr = (struct lecdatahdr_8025 *)skb->data;
@@ -2152,26 +2150,26 @@
 #endif
         src = hdr->h_source;
 
-        lec_arp_lock(priv);
+        lec_arp_get(priv);
         entry = priv->lec_arp_empty_ones;
         if (vcc == entry->vcc) {
-                save_flags(flags);
-                cli();
+		spin_lock_irqsave(&lec_arp_spinlock, flags);
                 del_timer(&entry->timer);
                 memcpy(entry->mac_addr, src, ETH_ALEN);
                 entry->status = ESI_FORWARD_DIRECT;
                 entry->last_used = jiffies;
                 priv->lec_arp_empty_ones = entry->next;
-                restore_flags(flags);
+                spin_unlock_irqrestore(&lec_arp_spinlock, flags);
                 /* We might have got an entry */
                 if ((prev=lec_arp_find(priv,src))) {
                         lec_arp_remove(priv->lec_arp_tables, prev);
                         kfree(prev);
                 }
-                lec_arp_put(priv->lec_arp_tables, entry);
-                lec_arp_unlock(priv);
+                lec_arp_add(priv->lec_arp_tables, entry);
+                lec_arp_put(priv);
                 return;
         }
+        spin_lock_irqsave(&lec_arp_spinlock, flags);
         prev = entry;
         entry = entry->next;
         while (entry && entry->vcc != vcc) {
@@ -2180,22 +2178,21 @@
         }
         if (!entry) {
                 DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
-                lec_arp_unlock(priv);
+                lec_arp_put(priv);
+                spin_unlock_irqrestore(&lec_arp_spinlock, flags);
                 return;
         }
-        save_flags(flags);
-        cli();
         del_timer(&entry->timer);
         memcpy(entry->mac_addr, src, ETH_ALEN);
         entry->status = ESI_FORWARD_DIRECT;
         entry->last_used = jiffies;
         prev->next = entry->next;
-        restore_flags(flags);
+        spin_unlock_irqrestore(&lec_arp_spinlock, flags);
         if ((prev = lec_arp_find(priv, src))) {
                 lec_arp_remove(priv->lec_arp_tables,prev);
                 kfree(prev);
         }
-        lec_arp_put(priv->lec_arp_tables,entry);
-        lec_arp_unlock(priv);  
+        lec_arp_add(priv->lec_arp_tables,entry);
+        lec_arp_put(priv);  
 }
 MODULE_LICENSE("GPL");
