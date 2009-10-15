From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] (updated) netfilter: remove deprecated CONFIG_NF_CT_ACCT
Date: Thu, 15 Oct 2009 03:59:30 -0400
Message-ID: <20091015080211.4561.78538.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Krzysztof Piotr Oledzki <ole@ans.pl>,
	Amerigo Wang <amwang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761458AbZJOIAR@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


CONFIG_NF_CT_ACCT is scheduled to be removed in 2.6.29.

Cc: Krzysztof Piotr Oledzki <ole@ans.pl>
Signed-off-by: WANG Cong <amwang@redhat.com>

---

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 04e6c81..3170c85 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -345,15 +345,6 @@ Who:	Johannes Berg <johannes@sipsolutions.net>
 
 ---------------------------
 
-What: CONFIG_NF_CT_ACCT
-When: 2.6.29
-Why:  Accounting can now be enabled/disabled without kernel recompilation.
-      Currently used only to set a default value for a feature that is also
-      controlled by a kernel/module/sysfs/sysctl parameter.
-Who:  Krzysztof Piotr Oledzki <ole@ans.pl>
-
----------------------------
-
 What:	sysfs ui for changing p4-clockmod parameters
 When:	September 2009
 Why:	See commits 129f8ae9b1b5be94517da76009ea956e89104ce8 and
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 9107b38..722b2be 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1534,8 +1534,7 @@ and is between 256 and 4096 characters. It is defined in the file
 			[NETFILTER] Enable connection tracking flow accounting
 			0 to disable accounting
 			1 to enable accounting
-			Default value depends on CONFIG_NF_CT_ACCT that is
-			going to be removed in 2.6.29.
+			Default value is 1.
 
 	nfsaddrs=	[NFS]
 			See Documentation/filesystems/nfsroot.txt.
diff --git a/arch/alpha/defconfig b/arch/alpha/defconfig
index e43f68f..5c98dc1 100644
--- a/arch/alpha/defconfig
+++ b/arch/alpha/defconfig
@@ -370,7 +370,6 @@ CONFIG_NETFILTER=y
 # IP: Netfilter Configuration
 #
 CONFIG_IP_NF_CONNTRACK=m
-# CONFIG_IP_NF_CT_ACCT is not set
 # CONFIG_IP_NF_CT_PROTO_SCTP is not set
 CONFIG_IP_NF_FTP=m
 CONFIG_IP_NF_IRC=m
diff --git a/arch/arm/configs/ebsa110_defconfig b/arch/arm/configs/ebsa110_defconfig
index afcfff6..6faf3ee 100644
--- a/arch/arm/configs/ebsa110_defconfig
+++ b/arch/arm/configs/ebsa110_defconfig
@@ -284,7 +284,6 @@ CONFIG_NETFILTER=y
 # IP: Netfilter Configuration
 #
 CONFIG_IP_NF_CONNTRACK=y
-# CONFIG_IP_NF_CT_ACCT is not set
 # CONFIG_IP_NF_CONNTRACK_MARK is not set
 # CONFIG_IP_NF_CT_PROTO_SCTP is not set
 CONFIG_IP_NF_FTP=y
diff --git a/arch/arm/configs/ezx_defconfig b/arch/arm/configs/ezx_defconfig
index d5ee16e..698de70 100644
--- a/arch/arm/configs/ezx_defconfig
+++ b/arch/arm/configs/ezx_defconfig
@@ -376,7 +376,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/arm/configs/netwinder_defconfig b/arch/arm/configs/netwinder_defconfig
index c1a63a3..7728932 100644
--- a/arch/arm/configs/netwinder_defconfig
+++ b/arch/arm/configs/netwinder_defconfig
@@ -345,7 +345,6 @@ CONFIG_NETFILTER=y
 # IP: Netfilter Configuration
 #
 CONFIG_IP_NF_CONNTRACK=y
-# CONFIG_IP_NF_CT_ACCT is not set
 # CONFIG_IP_NF_CONNTRACK_MARK is not set
 # CONFIG_IP_NF_CT_PROTO_SCTP is not set
 CONFIG_IP_NF_FTP=y
diff --git a/arch/arm/configs/netx_defconfig b/arch/arm/configs/netx_defconfig
index 61d0fc5..89cb82d 100644
--- a/arch/arm/configs/netx_defconfig
+++ b/arch/arm/configs/netx_defconfig
@@ -265,7 +265,6 @@ CONFIG_NETFILTER=y
 # IP: Netfilter Configuration
 #
 CONFIG_IP_NF_CONNTRACK=m
-# CONFIG_IP_NF_CT_ACCT is not set
 # CONFIG_IP_NF_CONNTRACK_MARK is not set
 # CONFIG_IP_NF_CONNTRACK_EVENTS is not set
 # CONFIG_IP_NF_CT_PROTO_SCTP is not set
diff --git a/arch/arm/configs/pnx4008_defconfig b/arch/arm/configs/pnx4008_defconfig
index 67b5f1e..f7442d7 100644
--- a/arch/arm/configs/pnx4008_defconfig
+++ b/arch/arm/configs/pnx4008_defconfig
@@ -309,7 +309,6 @@ CONFIG_BRIDGE_NETFILTER=y
 # IP: Netfilter Configuration
 #
 CONFIG_IP_NF_CONNTRACK=m
-CONFIG_IP_NF_CT_ACCT=y
 CONFIG_IP_NF_CONNTRACK_MARK=y
 # CONFIG_IP_NF_CONNTRACK_EVENTS is not set
 CONFIG_IP_NF_CT_PROTO_SCTP=m
diff --git a/arch/arm/configs/s3c2410_defconfig b/arch/arm/configs/s3c2410_defconfig
index b498104..817c03d 100644
--- a/arch/arm/configs/s3c2410_defconfig
+++ b/arch/arm/configs/s3c2410_defconfig
@@ -480,7 +480,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 CONFIG_NF_CT_PROTO_DCCP=m
diff --git a/arch/m68k/configs/amiga_defconfig b/arch/m68k/configs/amiga_defconfig
index 0f69fa5..26a0469 100644
--- a/arch/m68k/configs/amiga_defconfig
+++ b/arch/m68k/configs/amiga_defconfig
@@ -251,7 +251,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/apollo_defconfig b/arch/m68k/configs/apollo_defconfig
index 5fff581..5b42613 100644
--- a/arch/m68k/configs/apollo_defconfig
+++ b/arch/m68k/configs/apollo_defconfig
@@ -246,7 +246,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/atari_defconfig b/arch/m68k/configs/atari_defconfig
index d92a90e..5472ec5 100644
--- a/arch/m68k/configs/atari_defconfig
+++ b/arch/m68k/configs/atari_defconfig
@@ -247,7 +247,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/bvme6000_defconfig b/arch/m68k/configs/bvme6000_defconfig
index 6e6b1aa..a81d838 100644
--- a/arch/m68k/configs/bvme6000_defconfig
+++ b/arch/m68k/configs/bvme6000_defconfig
@@ -248,7 +248,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/hp300_defconfig b/arch/m68k/configs/hp300_defconfig
index bc0565f..e32903f 100644
--- a/arch/m68k/configs/hp300_defconfig
+++ b/arch/m68k/configs/hp300_defconfig
@@ -247,7 +247,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/mac_defconfig b/arch/m68k/configs/mac_defconfig
index 9991b64..3554ed6 100644
--- a/arch/m68k/configs/mac_defconfig
+++ b/arch/m68k/configs/mac_defconfig
@@ -245,7 +245,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/multi_defconfig b/arch/m68k/configs/multi_defconfig
index 69c43e2..56c3f94 100644
--- a/arch/m68k/configs/multi_defconfig
+++ b/arch/m68k/configs/multi_defconfig
@@ -258,7 +258,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/mvme147_defconfig b/arch/m68k/configs/mvme147_defconfig
index 7dceb5d..607f079 100644
--- a/arch/m68k/configs/mvme147_defconfig
+++ b/arch/m68k/configs/mvme147_defconfig
@@ -248,7 +248,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/mvme16x_defconfig b/arch/m68k/configs/mvme16x_defconfig
index 890594f..b266c9a 100644
--- a/arch/m68k/configs/mvme16x_defconfig
+++ b/arch/m68k/configs/mvme16x_defconfig
@@ -248,7 +248,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/q40_defconfig b/arch/m68k/configs/q40_defconfig
index 7cf58c2..c93cd2c 100644
--- a/arch/m68k/configs/q40_defconfig
+++ b/arch/m68k/configs/q40_defconfig
@@ -245,7 +245,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/sun3_defconfig b/arch/m68k/configs/sun3_defconfig
index f27c1a4..309f8c3 100644
--- a/arch/m68k/configs/sun3_defconfig
+++ b/arch/m68k/configs/sun3_defconfig
@@ -243,7 +243,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/sun3x_defconfig b/arch/m68k/configs/sun3x_defconfig
index c40edb9..1b8a899 100644
--- a/arch/m68k/configs/sun3x_defconfig
+++ b/arch/m68k/configs/sun3x_defconfig
@@ -245,7 +245,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/mips/configs/ar7_defconfig b/arch/mips/configs/ar7_defconfig
index 3564830..302d99f 100644
--- a/arch/mips/configs/ar7_defconfig
+++ b/arch/mips/configs/ar7_defconfig
@@ -359,7 +359,6 @@ CONFIG_NETFILTER_ADVANCED=y
 # CONFIG_NETFILTER_NETLINK_QUEUE is not set
 # CONFIG_NETFILTER_NETLINK_LOG is not set
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/mips/configs/bcm47xx_defconfig b/arch/mips/configs/bcm47xx_defconfig
index 94b7d57..fb6edc2 100644
--- a/arch/mips/configs/bcm47xx_defconfig
+++ b/arch/mips/configs/bcm47xx_defconfig
@@ -401,7 +401,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/db1000_defconfig b/arch/mips/configs/db1000_defconfig
index dbdf3bb..0c82c42 100644
--- a/arch/mips/configs/db1000_defconfig
+++ b/arch/mips/configs/db1000_defconfig
@@ -326,7 +326,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/db1100_defconfig b/arch/mips/configs/db1100_defconfig
index fa68144..0bebb8d 100644
--- a/arch/mips/configs/db1100_defconfig
+++ b/arch/mips/configs/db1100_defconfig
@@ -315,7 +315,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/db1200_defconfig b/arch/mips/configs/db1200_defconfig
index d73f1de..4d35b72 100644
--- a/arch/mips/configs/db1200_defconfig
+++ b/arch/mips/configs/db1200_defconfig
@@ -320,7 +320,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/db1500_defconfig b/arch/mips/configs/db1500_defconfig
index ec3e028..7e739ba 100644
--- a/arch/mips/configs/db1500_defconfig
+++ b/arch/mips/configs/db1500_defconfig
@@ -333,7 +333,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/db1550_defconfig b/arch/mips/configs/db1550_defconfig
index 7631dae..6e7e005 100644
--- a/arch/mips/configs/db1550_defconfig
+++ b/arch/mips/configs/db1550_defconfig
@@ -332,7 +332,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/ip22_defconfig b/arch/mips/configs/ip22_defconfig
index f14d38b..29e1aa8 100644
--- a/arch/mips/configs/ip22_defconfig
+++ b/arch/mips/configs/ip22_defconfig
@@ -364,7 +364,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/jazz_defconfig b/arch/mips/configs/jazz_defconfig
index d22df61..feb1c63 100644
--- a/arch/mips/configs/jazz_defconfig
+++ b/arch/mips/configs/jazz_defconfig
@@ -341,7 +341,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/malta_defconfig b/arch/mips/configs/malta_defconfig
index 3f01870..a59d654 100644
--- a/arch/mips/configs/malta_defconfig
+++ b/arch/mips/configs/malta_defconfig
@@ -397,7 +397,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/markeins_defconfig b/arch/mips/configs/markeins_defconfig
index d001f7e..004cb26 100644
--- a/arch/mips/configs/markeins_defconfig
+++ b/arch/mips/configs/markeins_defconfig
@@ -340,7 +340,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/pb1100_defconfig b/arch/mips/configs/pb1100_defconfig
index be8091e..d1e8642 100644
--- a/arch/mips/configs/pb1100_defconfig
+++ b/arch/mips/configs/pb1100_defconfig
@@ -327,7 +327,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/pb1500_defconfig b/arch/mips/configs/pb1500_defconfig
index e74ba79..d14b215 100644
--- a/arch/mips/configs/pb1500_defconfig
+++ b/arch/mips/configs/pb1500_defconfig
@@ -332,7 +332,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/pb1550_defconfig b/arch/mips/configs/pb1550_defconfig
index 1d896fd..1d42d40 100644
--- a/arch/mips/configs/pb1550_defconfig
+++ b/arch/mips/configs/pb1550_defconfig
@@ -333,7 +333,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/rb532_defconfig b/arch/mips/configs/rb532_defconfig
index f40c3a0..db3a2ee 100644
--- a/arch/mips/configs/rb532_defconfig
+++ b/arch/mips/configs/rb532_defconfig
@@ -340,7 +340,6 @@ CONFIG_NETFILTER_ADVANCED=y
 # CONFIG_NETFILTER_NETLINK_QUEUE is not set
 # CONFIG_NETFILTER_NETLINK_LOG is not set
 CONFIG_NF_CONNTRACK=y
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/mips/configs/rm200_defconfig b/arch/mips/configs/rm200_defconfig
index e53b8d0..efb2bc1 100644
--- a/arch/mips/configs/rm200_defconfig
+++ b/arch/mips/configs/rm200_defconfig
@@ -353,7 +353,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/powerpc/configs/g5_defconfig b/arch/powerpc/configs/g5_defconfig
index fc90592..32d5628 100644
--- a/arch/powerpc/configs/g5_defconfig
+++ b/arch/powerpc/configs/g5_defconfig
@@ -354,7 +354,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/iseries_defconfig b/arch/powerpc/configs/iseries_defconfig
index f925c55..7697f0b 100644
--- a/arch/powerpc/configs/iseries_defconfig
+++ b/arch/powerpc/configs/iseries_defconfig
@@ -336,7 +336,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/linkstation_defconfig b/arch/powerpc/configs/linkstation_defconfig
index 45671e7..e9be1a6 100644
--- a/arch/powerpc/configs/linkstation_defconfig
+++ b/arch/powerpc/configs/linkstation_defconfig
@@ -376,7 +376,6 @@ CONFIG_NETFILTER_ADVANCED=y
 # CONFIG_NETFILTER_NETLINK_QUEUE is not set
 # CONFIG_NETFILTER_NETLINK_LOG is not set
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 # CONFIG_NF_CONNTRACK_MARK is not set
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/pmac32_defconfig b/arch/powerpc/configs/pmac32_defconfig
index ea8870a..fcb169a 100644
--- a/arch/powerpc/configs/pmac32_defconfig
+++ b/arch/powerpc/configs/pmac32_defconfig
@@ -400,7 +400,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 # CONFIG_NF_CONNTRACK_MARK is not set
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 CONFIG_NF_CT_PROTO_DCCP=m
diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/ppc64_defconfig
index 2524018..af11f6e 100644
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -463,7 +463,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/ppc6xx_defconfig b/arch/powerpc/configs/ppc6xx_defconfig
index 12dc7c4..44b711e 100644
--- a/arch/powerpc/configs/ppc6xx_defconfig
+++ b/arch/powerpc/configs/ppc6xx_defconfig
@@ -511,7 +511,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index f1889ab..51ddc35 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -371,7 +371,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/s390/defconfig b/arch/s390/defconfig
index ab44644..e9ffa25 100644
--- a/arch/s390/defconfig
+++ b/arch/s390/defconfig
@@ -356,7 +356,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 # CONFIG_NF_CONNTRACK_MARK is not set
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 634d14a..5dfe7ec 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -40,27 +40,6 @@ config NF_CONNTRACK
 
 if NF_CONNTRACK
 
-config NF_CT_ACCT
-	bool "Connection tracking flow accounting"
-	depends on NETFILTER_ADVANCED
-	help
-	  If this option is enabled, the connection tracking code will
-	  keep per-flow packet and byte counters.
-
-	  Those counters can be used for flow-based accounting or the
-	  `connbytes' match.
-
-	  Please note that currently this option only sets a default state.
-	  You may change it at boot time with nf_conntrack.acct=0/1 kernel
-	  parameter or by loading the nf_conntrack module with acct=0/1.
-
-	  You may also disable/enable it on a running system with:
-	   sysctl net.netfilter.nf_conntrack_acct=0/1
-
-	  This option will be removed in 2.6.29.
-
-	  If unsure, say `N'.
-
 config NF_CONNTRACK_MARK
 	bool  'Connection mark tracking support'
 	depends on NETFILTER_ADVANCED
@@ -557,7 +536,6 @@ config NETFILTER_XT_MATCH_CONNBYTES
 	tristate  '"connbytes" per-connection counter match support'
 	depends on NF_CONNTRACK
 	depends on NETFILTER_ADVANCED
-	select NF_CT_ACCT
 	help
 	  This option adds a `connbytes' match, which allows you to match the
 	  number of bytes and/or packets for each direction within a connection.
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 4a1d94a..2c4464d 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -16,13 +16,7 @@
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_acct.h>
 
-#ifdef CONFIG_NF_CT_ACCT
-#define NF_CT_ACCT_DEFAULT 1
-#else
-#define NF_CT_ACCT_DEFAULT 0
-#endif
-
-static int nf_ct_acct __read_mostly = NF_CT_ACCT_DEFAULT;
+static int nf_ct_acct __read_mostly = 1;
 
 module_param_named(acct, nf_ct_acct, bool, 0644);
 MODULE_PARM_DESC(acct, "Enable connection tracking flow accounting.");
@@ -114,11 +108,6 @@ int nf_conntrack_acct_init(struct net *net)
 	net->ct.sysctl_acct = nf_ct_acct;
 
 	if (net_eq(net, &init_net)) {
-#ifdef CONFIG_NF_CT_ACCT
-	printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use\n");
-		printk(KERN_WARNING "nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or\n");
-		printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
-#endif
 
 		ret = nf_ct_extend_register(&acct_extend);
 		if (ret < 0) {
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 59d8064..d679562 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -430,11 +430,9 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	       + 3 * nla_total_size(sizeof(u_int8_t)) /* CTA_PROTO_NUM */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_ID */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_STATUS */
-#ifdef CONFIG_NF_CT_ACCT
 	       + 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
 	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
 	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
-#endif
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_TIMEOUT */
 	       + nla_total_size(0) /* CTA_PROTOINFO */
 	       + nla_total_size(0) /* CTA_HELP */
