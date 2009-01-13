From: Jaswinder Singh Rajput <jaswinder@infradead.org>
Subject: [PULL -tip] fixed few make headers_check warnings
Date: Tue, 13 Jan 2009 14:10:16 +0530
Message-ID: <1231836016.3212.41.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKM
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39460 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333AbZAMImp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 03:42:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ingo,

Please pull these patches. Earlier I also floated these patches so that I can get some feedback.

The following changes since commit ae2659bcd0b5bf34dd4b03f1db0a2942cc09b8e6:
  Ingo Molnar (1):
        Merge branch 'x86/mm'

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tiptop.git master

Jaswinder Singh Rajput (7):
      include of <linux/types.h> is preferred over <asm/types.h>
      found __[us]{8,16,32,64} type without #include <linux/types.h>
      capability.h: extern's make no sense in userspace
      coda_psdev.h: extern's make no sense in userspace
      in6.h: extern's make no sense in userspace
      nubus.h: extern's make no sense in userspace
      socket.h: extern's make no sense in userspace

 include/linux/agpgart.h        |    1 -
 include/linux/aio_abi.h        |    1 +
 include/linux/atalk.h          |    1 +
 include/linux/atm_idt77105.h   |    2 +-
 include/linux/atmbr2684.h      |    1 +
 include/linux/auto_fs4.h       |    1 +
 include/linux/bfs_fs.h         |    2 ++
 include/linux/blktrace_api.h   |    2 ++
 include/linux/capability.h     |    8 ++++----
 include/linux/capi.h           |    2 +-
 include/linux/cdrom.h          |    1 +
 include/linux/cgroupstats.h    |    1 +
 include/linux/coda_psdev.h     |    2 ++
 include/linux/connector.h      |    2 +-
 include/linux/cyclades.h       |    2 --
 include/linux/dlm_plock.h      |    2 ++
 include/linux/dn.h             |    2 ++
 include/linux/edd.h            |    2 ++
 include/linux/efs_fs_sb.h      |    1 +
 include/linux/errqueue.h       |    2 ++
 include/linux/fb.h             |    2 +-
 include/linux/genetlink.h      |    1 +
 include/linux/gfs2_ondisk.h    |    2 ++
 include/linux/hiddev.h         |    2 ++
 include/linux/icmpv6.h         |    1 +
 include/linux/if_addr.h        |    1 +
 include/linux/if_addrlabel.h   |    2 ++
 include/linux/if_fc.h          |    1 +
 include/linux/if_hippi.h       |    1 +
 include/linux/if_link.h        |    1 +
 include/linux/if_ppp.h         |    1 +
 include/linux/if_pppol2tp.h    |    2 +-
 include/linux/if_pppox.h       |    2 +-
 include/linux/if_strip.h       |    2 ++
 include/linux/if_tr.h          |    1 +
 include/linux/igmp.h           |    1 +
 include/linux/in6.h            |    2 +-
 include/linux/inet_diag.h      |    2 ++
 include/linux/input.h          |    2 +-
 include/linux/ip6_tunnel.h     |    2 ++
 include/linux/ipv6.h           |    1 +
 include/linux/ipv6_route.h     |    2 ++
 include/linux/ipx.h            |    1 +
 include/linux/irda.h           |    2 ++
 include/linux/joystick.h       |    2 +-
 include/linux/kvm.h            |    2 +-
 include/linux/loop.h           |    2 +-
 include/linux/matroxfb.h       |    2 +-
 include/linux/minix_fs.h       |    1 +
 include/linux/msdos_fs.h       |    1 +
 include/linux/neighbour.h      |    1 +
 include/linux/nfs_idmap.h      |    2 ++
 include/linux/nubus.h          |    5 ++++-
 include/linux/phantom.h        |    2 +-
 include/linux/phonet.h         |    2 ++
 include/linux/pkt_cls.h        |    1 +
 include/linux/pkt_sched.h      |    2 ++
 include/linux/ppp_defs.h       |    2 ++
 include/linux/radeonfb.h       |    2 +-
 include/linux/random.h         |    1 +
 include/linux/rtnetlink.h      |    1 +
 include/linux/signalfd.h       |    1 +
 include/linux/socket.h         |   10 +++++-----
 include/linux/synclink.h       |    2 ++
 include/linux/taskstats.h      |    2 ++
 include/linux/video_decoder.h  |    2 ++
 include/linux/video_encoder.h  |    2 ++
 include/linux/videodev.h       |    1 +
 include/linux/virtio_blk.h     |    1 +
 include/linux/virtio_console.h |    2 ++
 include/linux/virtio_net.h     |    2 ++
 71 files changed, 104 insertions(+), 27 deletions(-)

diff --git a/include/linux/agpgart.h b/include/linux/agpgart.h
index c8fdb6e..110c600 100644
--- a/include/linux/agpgart.h
+++ b/include/linux/agpgart.h
@@ -52,7 +52,6 @@
 
 #ifndef __KERNEL__
 #include <linux/types.h>
-#include <asm/types.h>
 
 struct agp_version {
 	__u16 major;
diff --git a/include/linux/aio_abi.h b/include/linux/aio_abi.h
index 9e01729..2c87316 100644
--- a/include/linux/aio_abi.h
+++ b/include/linux/aio_abi.h
@@ -27,6 +27,7 @@
 #ifndef __LINUX__AIO_ABI_H
 #define __LINUX__AIO_ABI_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 typedef unsigned long	aio_context_t;
diff --git a/include/linux/atalk.h b/include/linux/atalk.h
index e9ebac2..d34c187 100644
--- a/include/linux/atalk.h
+++ b/include/linux/atalk.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_ATALK_H__
 #define __LINUX_ATALK_H__
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 /*
diff --git a/include/linux/atm_idt77105.h b/include/linux/atm_idt77105.h
index 05621cf..8b72400 100644
--- a/include/linux/atm_idt77105.h
+++ b/include/linux/atm_idt77105.h
@@ -7,7 +7,7 @@
 #ifndef LINUX_ATM_IDT77105_H
 #define LINUX_ATM_IDT77105_H
 
-#include <asm/types.h>
+#include <linux/types.h>
 #include <linux/atmioc.h>
 #include <linux/atmdev.h>
 
diff --git a/include/linux/atmbr2684.h b/include/linux/atmbr2684.h
index 52bf72a..fdb2629 100644
--- a/include/linux/atmbr2684.h
+++ b/include/linux/atmbr2684.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_ATMBR2684_H
 #define _LINUX_ATMBR2684_H
 
+#include <linux/types.h>
 #include <linux/atm.h>
 #include <linux/if.h>		/* For IFNAMSIZ */
 
diff --git a/include/linux/auto_fs4.h b/include/linux/auto_fs4.h
index 55fa478..2b60077 100644
--- a/include/linux/auto_fs4.h
+++ b/include/linux/auto_fs4.h
@@ -11,6 +11,7 @@
 #ifndef _LINUX_AUTO_FS4_H
 #define _LINUX_AUTO_FS4_H
 
+#include <linux/types.h>
 /* Include common v3 definitions */
 #include <linux/auto_fs.h>
 
diff --git a/include/linux/bfs_fs.h b/include/linux/bfs_fs.h
index 8ed6dfd..2ca3e8f 100644
--- a/include/linux/bfs_fs.h
+++ b/include/linux/bfs_fs.h
@@ -6,6 +6,8 @@
 #ifndef _LINUX_BFS_FS_H
 #define _LINUX_BFS_FS_H
 
+#include <linux/types.h>
+
 #define BFS_BSIZE_BITS		9
 #define BFS_BSIZE		(1<<BFS_BSIZE_BITS)
 
diff --git a/include/linux/blktrace_api.h b/include/linux/blktrace_api.h
index 1dba349..e9ef923 100644
--- a/include/linux/blktrace_api.h
+++ b/include/linux/blktrace_api.h
@@ -6,6 +6,8 @@
 #include <linux/relay.h>
 #endif
 
+#include <linux/types.h>
+
 /*
  * Trace categories
  */
diff --git a/include/linux/capability.h b/include/linux/capability.h
index 02bdb76..1b98725 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -69,10 +69,6 @@ typedef struct __user_cap_data_struct {
 #define VFS_CAP_U32             VFS_CAP_U32_2
 #define VFS_CAP_REVISION	VFS_CAP_REVISION_2
 
-#ifdef CONFIG_SECURITY_FILE_CAPABILITIES
-extern int file_caps_enabled;
-#endif
-
 struct vfs_cap_data {
 	__le32 magic_etc;            /* Little endian */
 	struct {
@@ -96,6 +92,10 @@ struct vfs_cap_data {
 #define _KERNEL_CAPABILITY_VERSION _LINUX_CAPABILITY_VERSION_3
 #define _KERNEL_CAPABILITY_U32S    _LINUX_CAPABILITY_U32S_3
 
+#ifdef CONFIG_SECURITY_FILE_CAPABILITIES
+extern int file_caps_enabled;
+#endif
+
 typedef struct kernel_cap_struct {
 	__u32 cap[_KERNEL_CAPABILITY_U32S];
 } kernel_cap_t;
diff --git a/include/linux/capi.h b/include/linux/capi.h
index fdebaaa..65100d6 100644
--- a/include/linux/capi.h
+++ b/include/linux/capi.h
@@ -12,7 +12,7 @@
 #ifndef __LINUX_CAPI_H__
 #define __LINUX_CAPI_H__
 
-#include <asm/types.h>
+#include <linux/types.h>
 #include <linux/ioctl.h>
 #ifndef __KERNEL__
 #include <linux/kernelcapi.h>
diff --git a/include/linux/cdrom.h b/include/linux/cdrom.h
index 0b49e08..78e9047 100644
--- a/include/linux/cdrom.h
+++ b/include/linux/cdrom.h
@@ -11,6 +11,7 @@
 #ifndef	_LINUX_CDROM_H
 #define	_LINUX_CDROM_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 /*******************************************************
diff --git a/include/linux/cgroupstats.h b/include/linux/cgroupstats.h
index 4f53abf..3753c33 100644
--- a/include/linux/cgroupstats.h
+++ b/include/linux/cgroupstats.h
@@ -15,6 +15,7 @@
 #ifndef _LINUX_CGROUPSTATS_H
 #define _LINUX_CGROUPSTATS_H
 
+#include <linux/types.h>
 #include <linux/taskstats.h>
 
 /*
diff --git a/include/linux/coda_psdev.h b/include/linux/coda_psdev.h
index 07ae8f8..c620958 100644
--- a/include/linux/coda_psdev.h
+++ b/include/linux/coda_psdev.h
@@ -87,6 +87,8 @@ struct upc_req {
  * Statistics
  */
 
+#ifdef __KERNEL__
 extern struct venus_comm coda_comms[];
+#endif /* __KERNEL__ */
 
 #endif
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 5c7f946..34f2789 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -22,7 +22,7 @@
 #ifndef __CONNECTOR_H
 #define __CONNECTOR_H
 
-#include <asm/types.h>
+#include <linux/types.h>
 
 #define CN_IDX_CONNECTOR		0xffffffff
 #define CN_VAL_CONNECTOR		0xffffffff
diff --git a/include/linux/cyclades.h b/include/linux/cyclades.h
index 2d3d1e0..d06fbf2 100644
--- a/include/linux/cyclades.h
+++ b/include/linux/cyclades.h
@@ -150,8 +150,6 @@ struct CYZ_BOOT_CTRL {
  *	architectures and compilers.
  */
 
-#include <asm/types.h>
-
 typedef __u64  ucdouble;		/* 64 bits, unsigned */
 typedef __u32  uclong;			/* 32 bits, unsigned */
 typedef __u16  ucshort;		/* 16 bits, unsigned */
diff --git a/include/linux/dlm_plock.h b/include/linux/dlm_plock.h
index 18d5fdb..2dd2124 100644
--- a/include/linux/dlm_plock.h
+++ b/include/linux/dlm_plock.h
@@ -9,6 +9,8 @@
 #ifndef __DLM_PLOCK_DOT_H__
 #define __DLM_PLOCK_DOT_H__
 
+#include <linux/types.h>
+
 #define DLM_PLOCK_MISC_NAME		"dlm_plock"
 
 #define DLM_PLOCK_VERSION_MAJOR	1
diff --git a/include/linux/dn.h b/include/linux/dn.h
index 02bba04..fe99908 100644
--- a/include/linux/dn.h
+++ b/include/linux/dn.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_DN_H
 #define _LINUX_DN_H
 
+#include <linux/types.h>
+
 /*
 
 	DECnet Data Structures and Constants
diff --git a/include/linux/edd.h b/include/linux/edd.h
index 5d747c5..4cbd0fe 100644
--- a/include/linux/edd.h
+++ b/include/linux/edd.h
@@ -30,6 +30,8 @@
 #ifndef _LINUX_EDD_H
 #define _LINUX_EDD_H
 
+#include <linux/types.h>
+
 #define EDDNR 0x1e9		/* addr of number of edd_info structs at EDDBUF
 				   in boot_params - treat this as 1 byte  */
 #define EDDBUF	0xd00		/* addr of edd_info structs in boot_params */
diff --git a/include/linux/efs_fs_sb.h b/include/linux/efs_fs_sb.h
index ff1945e..a01be90 100644
--- a/include/linux/efs_fs_sb.h
+++ b/include/linux/efs_fs_sb.h
@@ -9,6 +9,7 @@
 #ifndef __EFS_FS_SB_H__
 #define __EFS_FS_SB_H__
 
+#include <linux/types.h>
 #include <linux/magic.h>
 
 /* EFS superblock magic numbers */
diff --git a/include/linux/errqueue.h b/include/linux/errqueue.h
index 92f8d4f..ceb1454 100644
--- a/include/linux/errqueue.h
+++ b/include/linux/errqueue.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_ERRQUEUE_H
 #define _LINUX_ERRQUEUE_H 1
 
+#include <linux/types.h>
+
 struct sock_extended_err
 {
 	__u32	ee_errno;	
diff --git a/include/linux/fb.h b/include/linux/fb.h
index 1ee63df..818fe21 100644
--- a/include/linux/fb.h
+++ b/include/linux/fb.h
@@ -1,7 +1,7 @@
 #ifndef _LINUX_FB_H
 #define _LINUX_FB_H
 
-#include <asm/types.h>
+#include <linux/types.h>
 #include <linux/i2c.h>
 
 struct dentry;
diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 7da02c9..b834ef6 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_GENERIC_NETLINK_H
 #define __LINUX_GENERIC_NETLINK_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 
 #define GENL_NAMSIZ	16	/* length of family name */
diff --git a/include/linux/gfs2_ondisk.h b/include/linux/gfs2_ondisk.h
index 14d0df0..c56b4bc 100644
--- a/include/linux/gfs2_ondisk.h
+++ b/include/linux/gfs2_ondisk.h
@@ -10,6 +10,8 @@
 #ifndef __GFS2_ONDISK_DOT_H__
 #define __GFS2_ONDISK_DOT_H__
 
+#include <linux/types.h>
+
 #define GFS2_MAGIC		0x01161970
 #define GFS2_BASIC_BLOCK	512
 #define GFS2_BASIC_BLOCK_SHIFT	9
diff --git a/include/linux/hiddev.h b/include/linux/hiddev.h
index c760ae0..bb6f58b 100644
--- a/include/linux/hiddev.h
+++ b/include/linux/hiddev.h
@@ -27,6 +27,8 @@
  * Vojtech Pavlik, Ucitelska 1576, Prague 8, 182 00 Czech Republic
  */
 
+#include <linux/types.h>
+
 /*
  * The event structure itself
  */
diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index a93a8dd..10d701e 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_ICMPV6_H
 #define _LINUX_ICMPV6_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 struct icmp6hdr {
diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index 43f3bed..a60c821 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_IF_ADDR_H
 #define __LINUX_IF_ADDR_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 
 struct ifaddrmsg
diff --git a/include/linux/if_addrlabel.h b/include/linux/if_addrlabel.h
index 9fe79c9..89571f6 100644
--- a/include/linux/if_addrlabel.h
+++ b/include/linux/if_addrlabel.h
@@ -10,6 +10,8 @@
 #ifndef __LINUX_IF_ADDRLABEL_H
 #define __LINUX_IF_ADDRLABEL_H
 
+#include <linux/types.h>
+
 struct ifaddrlblmsg
 {
 	__u8		ifal_family;		/* Address family */
diff --git a/include/linux/if_fc.h b/include/linux/if_fc.h
index 376a34e..6ed7f1b 100644
--- a/include/linux/if_fc.h
+++ b/include/linux/if_fc.h
@@ -20,6 +20,7 @@
 #ifndef _LINUX_IF_FC_H
 #define _LINUX_IF_FC_H
 
+#include <linux/types.h>
 
 #define FC_ALEN	6		/* Octets in one ethernet addr	 */
 #define FC_HLEN   (sizeof(struct fch_hdr)+sizeof(struct fcllc))
diff --git a/include/linux/if_hippi.h b/include/linux/if_hippi.h
index f0f2351..4a7c994 100644
--- a/include/linux/if_hippi.h
+++ b/include/linux/if_hippi.h
@@ -22,6 +22,7 @@
 #ifndef _LINUX_IF_HIPPI_H
 #define _LINUX_IF_HIPPI_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 /*
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f9032c8..176c518 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_IF_LINK_H
 #define _LINUX_IF_LINK_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 
 /* The struct should be in sync with struct net_device_stats */
diff --git a/include/linux/if_ppp.h b/include/linux/if_ppp.h
index c3b1f85..047a01c 100644
--- a/include/linux/if_ppp.h
+++ b/include/linux/if_ppp.h
@@ -34,6 +34,7 @@
 #define _IF_PPP_H_
 
 #include <linux/compiler.h>
+#include <linux/types.h>
 
 /*
  * Packet sizes
diff --git a/include/linux/if_pppol2tp.h b/include/linux/if_pppol2tp.h
index a7d6a22..c7a6688 100644
--- a/include/linux/if_pppol2tp.h
+++ b/include/linux/if_pppol2tp.h
@@ -15,7 +15,7 @@
 #ifndef __LINUX_IF_PPPOL2TP_H
 #define __LINUX_IF_PPPOL2TP_H
 
-#include <asm/types.h>
+#include <linux/types.h>
 
 #ifdef __KERNEL__
 #include <linux/in.h>
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 6fb7f17..30c88b2 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -17,7 +17,7 @@
 #define __LINUX_IF_PPPOX_H
 
 
-#include <asm/types.h>
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 #ifdef  __KERNEL__
diff --git a/include/linux/if_strip.h b/include/linux/if_strip.h
index fb5c5c9..6526a62 100644
--- a/include/linux/if_strip.h
+++ b/include/linux/if_strip.h
@@ -18,6 +18,8 @@
 #ifndef __LINUX_STRIP_H
 #define __LINUX_STRIP_H
 
+#include <linux/types.h>
+
 typedef struct {
     __u8 c[6];
 } MetricomAddress;
diff --git a/include/linux/if_tr.h b/include/linux/if_tr.h
index 5bcec8b..fc23aeb 100644
--- a/include/linux/if_tr.h
+++ b/include/linux/if_tr.h
@@ -19,6 +19,7 @@
 #ifndef _LINUX_IF_TR_H
 #define _LINUX_IF_TR_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>	/* For __be16 */
 
 /* IEEE 802.5 Token-Ring magic constants.  The frame sizes omit the preamble
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f734a0b..92fbd8c 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -16,6 +16,7 @@
 #ifndef _LINUX_IGMP_H
 #define _LINUX_IGMP_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 /*
diff --git a/include/linux/in6.h b/include/linux/in6.h
index bc49204..718bf21 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -44,11 +44,11 @@ struct in6_addr
  * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
  * in network byte order, not in host byte order as are the IPv4 equivalents
  */
+#ifdef __KERNEL__
 extern const struct in6_addr in6addr_any;
 #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
 extern const struct in6_addr in6addr_loopback;
 #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
-#ifdef __KERNEL__
 extern const struct in6_addr in6addr_linklocal_allnodes;
 #define IN6ADDR_LINKLOCAL_ALLNODES_INIT	\
 		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 6e8bc54..bc8c490 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -1,6 +1,8 @@
 #ifndef _INET_DIAG_H_
 #define _INET_DIAG_H_ 1
 
+#include <linux/types.h>
+
 /* Just some random number */
 #define TCPDIAG_GETSOCK 18
 #define DCCPDIAG_GETSOCK 19
diff --git a/include/linux/input.h b/include/linux/input.h
index 9a6355f..1249a0c 100644
--- a/include/linux/input.h
+++ b/include/linux/input.h
@@ -16,7 +16,7 @@
 #include <sys/time.h>
 #include <sys/ioctl.h>
 #include <sys/types.h>
-#include <asm/types.h>
+#include <linux/types.h>
 #endif
 
 /*
diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
index 1e7cc4a..acb9ad6 100644
--- a/include/linux/ip6_tunnel.h
+++ b/include/linux/ip6_tunnel.h
@@ -1,6 +1,8 @@
 #ifndef _IP6_TUNNEL_H
 #define _IP6_TUNNEL_H
 
+#include <linux/types.h>
+
 #define IPV6_TLV_TNL_ENCAP_LIMIT 4
 #define IPV6_DEFAULT_TNL_ENCAP_LIMIT 4
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0b816ca..476d946 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -1,6 +1,7 @@
 #ifndef _IPV6_H
 #define _IPV6_H
 
+#include <linux/types.h>
 #include <linux/in6.h>
 #include <asm/byteorder.h>
 
diff --git a/include/linux/ipv6_route.h b/include/linux/ipv6_route.h
index b323ff5..1e7d8af 100644
--- a/include/linux/ipv6_route.h
+++ b/include/linux/ipv6_route.h
@@ -13,6 +13,8 @@
 #ifndef _LINUX_IPV6_ROUTE_H
 #define _LINUX_IPV6_ROUTE_H
 
+#include <linux/types.h>
+
 #define RTF_DEFAULT	0x00010000	/* default - learned via ND	*/
 #define RTF_ALLONLINK	0x00020000	/* (deprecated and will be removed)
 					   fallback, no routers on link */
diff --git a/include/linux/ipx.h b/include/linux/ipx.h
index eb19b4e..aabb1d2 100644
--- a/include/linux/ipx.h
+++ b/include/linux/ipx.h
@@ -1,5 +1,6 @@
 #ifndef _IPX_H_
 #define _IPX_H_
+#include <linux/types.h>
 #include <linux/sockios.h>
 #include <linux/socket.h>
 #define IPX_NODE_LEN	6
diff --git a/include/linux/irda.h b/include/linux/irda.h
index 28f88ec..00bdad0 100644
--- a/include/linux/irda.h
+++ b/include/linux/irda.h
@@ -25,6 +25,8 @@
 #ifndef KERNEL_IRDA_H
 #define KERNEL_IRDA_H
 
+#include <linux/types.h>
+
 /* Please do *not* add any #include in this file, this file is
  * included as-is in user space.
  * Please fix the calling file to properly included needed files before
diff --git a/include/linux/joystick.h b/include/linux/joystick.h
index b5e0512..9e20c29 100644
--- a/include/linux/joystick.h
+++ b/include/linux/joystick.h
@@ -27,7 +27,7 @@
  * Vojtech Pavlik, Ucitelska 1576, Prague 8, 182 00 Czech Republic
  */
 
-#include <asm/types.h>
+#include <linux/types.h>
 #include <linux/input.h>
 
 /*
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index 35525ac..5715f19 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -7,7 +7,7 @@
  * Note: you must update KVM_API_VERSION if you change this interface.
  */
 
-#include <asm/types.h>
+#include <linux/types.h>
 #include <linux/compiler.h>
 #include <linux/ioctl.h>
 #include <asm/kvm.h>
diff --git a/include/linux/loop.h b/include/linux/loop.h
index 46169a7..6ffd6db 100644
--- a/include/linux/loop.h
+++ b/include/linux/loop.h
@@ -80,7 +80,7 @@ enum {
 };
 
 #include <asm/posix_types.h>	/* for __kernel_old_dev_t */
-#include <asm/types.h>		/* for __u64 */
+#include <linux/types.h>	/* for __u64 */
 
 /* Backwards compatibility version */
 struct loop_info {
diff --git a/include/linux/matroxfb.h b/include/linux/matroxfb.h
index ae5b094..404f678 100644
--- a/include/linux/matroxfb.h
+++ b/include/linux/matroxfb.h
@@ -2,7 +2,7 @@
 #define __LINUX_MATROXFB_H__
 
 #include <asm/ioctl.h>
-#include <asm/types.h>
+#include <linux/types.h>
 #include <linux/videodev2.h>
 
 struct matroxioc_output_mode {
diff --git a/include/linux/minix_fs.h b/include/linux/minix_fs.h
index 0e39745..13fe09e 100644
--- a/include/linux/minix_fs.h
+++ b/include/linux/minix_fs.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_MINIX_FS_H
 #define _LINUX_MINIX_FS_H
 
+#include <linux/types.h>
 #include <linux/magic.h>
 
 /*
diff --git a/include/linux/msdos_fs.h b/include/linux/msdos_fs.h
index e0a9b20..ce38f1c 100644
--- a/include/linux/msdos_fs.h
+++ b/include/linux/msdos_fs.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_MSDOS_FS_H
 #define _LINUX_MSDOS_FS_H
 
+#include <linux/types.h>
 #include <linux/magic.h>
 #include <asm/byteorder.h>
 
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index bd3bbf6..8730d5d 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_NEIGHBOUR_H
 #define __LINUX_NEIGHBOUR_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 
 struct ndmsg
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 15a9f3b..91a1c24 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -37,6 +37,8 @@
 #ifndef NFS_IDMAP_H
 #define NFS_IDMAP_H
 
+#include <linux/types.h>
+
 /* XXX from bits/utmp.h  */
 #define IDMAP_NAMESZ  128
 
diff --git a/include/linux/nubus.h b/include/linux/nubus.h
index c435507..9f54a23 100644
--- a/include/linux/nubus.h
+++ b/include/linux/nubus.h
@@ -12,6 +12,8 @@
 #ifndef LINUX_NUBUS_H
 #define LINUX_NUBUS_H
 
+#include <linux/types.h>
+
 #ifdef __KERNEL__
 #include <asm/nubus.h>
 #endif
@@ -295,6 +297,7 @@ struct nubus_dev {
 	struct nubus_board* board;
 };
 
+#ifdef __KERNEL__
 /* This is all NuBus devices (used to find devices later on) */
 extern struct nubus_dev* nubus_devices;
 /* This is all NuBus cards */
@@ -303,7 +306,7 @@ extern struct nubus_board* nubus_boards;
 /* Generic NuBus interface functions, modelled after the PCI interface */
 void nubus_scan_bus(void);
 extern void nubus_proc_init(void);
-int get_nubus_list(char *buf);
+#endif /* __KERNEL__ */
 int nubus_proc_attach_device(struct nubus_dev *dev);
 int nubus_proc_detach_device(struct nubus_dev *dev);
 /* If we need more precision we can add some more of these */
diff --git a/include/linux/phantom.h b/include/linux/phantom.h
index 02268c5..94dd664 100644
--- a/include/linux/phantom.h
+++ b/include/linux/phantom.h
@@ -10,7 +10,7 @@
 #ifndef __PHANTOM_H
 #define __PHANTOM_H
 
-#include <asm/types.h>
+#include <linux/types.h>
 
 /* PHN_(G/S)ET_REG param */
 struct phm_reg {
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 4157faa..ee5e3c9 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -23,6 +23,8 @@
 #ifndef LINUX_PHONET_H
 #define LINUX_PHONET_H
 
+#include <linux/types.h>
+
 /* Automatic protocol selection */
 #define PN_PROTO_TRANSPORT	0
 /* Phonet datagram socket */
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index e6aa848..3c842ed 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_PKT_CLS_H
 #define __LINUX_PKT_CLS_H
 
+#include <linux/types.h>
 #include <linux/pkt_sched.h>
 
 /* I think i could have done better macros ; for now this is stolen from
diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index e3f133a..b2648e8 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_PKT_SCHED_H
 #define __LINUX_PKT_SCHED_H
 
+#include <linux/types.h>
+
 /* Logical priority bands not depending on specific packet scheduler.
    Every scheduler will map them to real traffic classes, if it has
    no more precise mechanism to classify packets.
diff --git a/include/linux/ppp_defs.h b/include/linux/ppp_defs.h
index 6e8adc7..428017e 100644
--- a/include/linux/ppp_defs.h
+++ b/include/linux/ppp_defs.h
@@ -40,6 +40,8 @@
 #ifndef _PPP_DEFS_H_
 #define _PPP_DEFS_H_
 
+#include <linux/types.h>
+
 /*
  * The basic PPP frame.
  */
diff --git a/include/linux/radeonfb.h b/include/linux/radeonfb.h
index 5bd8975..8c4bbde 100644
--- a/include/linux/radeonfb.h
+++ b/include/linux/radeonfb.h
@@ -2,7 +2,7 @@
 #define __LINUX_RADEONFB_H__
 
 #include <asm/ioctl.h>
-#include <asm/types.h>
+#include <linux/types.h>
 
 #define ATY_RADEON_LCD_ON	0x00000001
 #define ATY_RADEON_CRT_ON	0x00000002
diff --git a/include/linux/random.h b/include/linux/random.h
index 407ea36..25d02fe 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -7,6 +7,7 @@
 #ifndef _LINUX_RANDOM_H
 #define _LINUX_RANDOM_H
 
+#include <linux/types.h>
 #include <linux/ioctl.h>
 #include <linux/irqnr.h>
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index e88f705..1e5f673 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_RTNETLINK_H
 #define __LINUX_RTNETLINK_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 #include <linux/if_link.h>
 #include <linux/if_addr.h>
diff --git a/include/linux/signalfd.h b/include/linux/signalfd.h
index bef0c46..b363b91 100644
--- a/include/linux/signalfd.h
+++ b/include/linux/signalfd.h
@@ -8,6 +8,7 @@
 #ifndef _LINUX_SIGNALFD_H
 #define _LINUX_SIGNALFD_H
 
+#include <linux/types.h>
 /* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/fcntl.h>
 
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 20fc4bb..f5771a2 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -24,11 +24,6 @@ struct __kernel_sockaddr_storage {
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
 
-#ifdef CONFIG_PROC_FS
-struct seq_file;
-extern void socket_seq_show(struct seq_file *seq);
-#endif
-
 typedef unsigned short	sa_family_t;
 
 /*
@@ -303,6 +298,11 @@ struct ucred {
 #define IPX_TYPE	1
 
 #ifdef __KERNEL__
+#ifdef CONFIG_PROC_FS
+struct seq_file;
+extern void socket_seq_show(struct seq_file *seq);
+#endif
+
 extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
 extern int memcpy_fromiovecend(unsigned char *kdata, struct iovec *iov, 
 				int offset, int len);
diff --git a/include/linux/synclink.h b/include/linux/synclink.h
index c844a22..99b8bdb 100644
--- a/include/linux/synclink.h
+++ b/include/linux/synclink.h
@@ -13,6 +13,8 @@
 #define _SYNCLINK_H_
 #define SYNCLINK_H_VERSION 3.6
 
+#include <linux/types.h>
+
 #define BIT0	0x0001
 #define BIT1	0x0002
 #define BIT2	0x0004
diff --git a/include/linux/taskstats.h b/include/linux/taskstats.h
index 18269e9..341dddb 100644
--- a/include/linux/taskstats.h
+++ b/include/linux/taskstats.h
@@ -16,6 +16,8 @@
 #ifndef _LINUX_TASKSTATS_H
 #define _LINUX_TASKSTATS_H
 
+#include <linux/types.h>
+
 /* Format for per-task data returned to userland when
  *	- a task exits
  *	- listener requests stats for a task
diff --git a/include/linux/video_decoder.h b/include/linux/video_decoder.h
index 121e26d..e26c0c8 100644
--- a/include/linux/video_decoder.h
+++ b/include/linux/video_decoder.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_VIDEO_DECODER_H
 #define _LINUX_VIDEO_DECODER_H
 
+#include <linux/types.h>
+
 #define HAVE_VIDEO_DECODER 1
 
 struct video_decoder_capability { /* this name is too long */
diff --git a/include/linux/video_encoder.h b/include/linux/video_encoder.h
index 4b0e690..b7b6423 100644
--- a/include/linux/video_encoder.h
+++ b/include/linux/video_encoder.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_VIDEO_ENCODER_H
 #define _LINUX_VIDEO_ENCODER_H
 
+#include <linux/types.h>
+
 struct video_encoder_capability { /* this name is too long */
 	__u32	flags;
 #define	VIDEO_ENCODER_PAL	1	/* can encode PAL signal */
diff --git a/include/linux/videodev.h b/include/linux/videodev.h
index 15a653d..837f392 100644
--- a/include/linux/videodev.h
+++ b/include/linux/videodev.h
@@ -12,6 +12,7 @@
 #ifndef __LINUX_VIDEODEV_H
 #define __LINUX_VIDEODEV_H
 
+#include <linux/types.h>
 #include <linux/ioctl.h>
 #include <linux/videodev2.h>
 
diff --git a/include/linux/virtio_blk.h b/include/linux/virtio_blk.h
index c1aef85..596df80 100644
--- a/include/linux/virtio_blk.h
+++ b/include/linux/virtio_blk.h
@@ -3,6 +3,7 @@
 /* This header is BSD licensed so anyone can use the definitions to implement
  * compatible drivers/servers. */
 #include <linux/virtio_config.h>
+#include <linux/types.h>
 
 /* The ID for virtio_block */
 #define VIRTIO_ID_BLOCK	2
diff --git a/include/linux/virtio_console.h b/include/linux/virtio_console.h
index 7615ffc..061c167 100644
--- a/include/linux/virtio_console.h
+++ b/include/linux/virtio_console.h
@@ -4,6 +4,8 @@
 /* This header, excluding the #ifdef __KERNEL__ part, is BSD licensed so
  * anyone can use the definitions to implement compatible drivers/servers. */
 
+#include <linux/types.h>
+
 /* The ID for virtio console */
 #define VIRTIO_ID_CONSOLE	3
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5cdd0aa..cf335fe 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -4,6 +4,8 @@
  * compatible drivers/servers. */
 #include <linux/virtio_config.h>
 
+#include <linux/types.h>
+
 /* The ID for virtio_net */
 #define VIRTIO_ID_NET	1
 


