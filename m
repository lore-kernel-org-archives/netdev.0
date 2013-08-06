From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: sctp: trivial: update bug report in header comment
Date: Tue,  6 Aug 2013 21:18:13 +0200
Message-ID: <1375816693-7697-2-git-send-email-dborkman@redhat.com>
References: <1375816693-7697-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755375Ab3HFTSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 15:18:18 -0400
In-Reply-To: <1375816693-7697-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the restructuring of the lksctp.org site, we only allow bug
reports through the SCTP mailing list linux-sctp@vger.kernel.org,
not via SF, as SF is only used for web hosting and nothing more.
While at it, also remove the obvious statement that bugs will be
fixed and incooperated into the kernel.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/auth.h      |  6 ------
 include/net/sctp/checksum.h  |  6 ------
 include/net/sctp/command.h   | 18 ++++++++----------
 include/net/sctp/constants.h |  6 ------
 include/net/sctp/sctp.h      |  6 ------
 include/net/sctp/sm.h        |  6 ------
 include/net/sctp/structs.h   |  6 ------
 include/net/sctp/tsnmap.h    |  6 ------
 include/net/sctp/ulpevent.h  |  6 ------
 include/net/sctp/ulpqueue.h  |  6 ------
 net/sctp/associola.c         |  6 ------
 net/sctp/auth.c              |  6 ------
 net/sctp/bind_addr.c         |  6 ------
 net/sctp/chunk.c             |  6 ------
 net/sctp/command.c           |  6 ------
 net/sctp/debug.c             |  6 ------
 net/sctp/endpointola.c       |  6 ------
 net/sctp/input.c             |  6 ------
 net/sctp/inqueue.c           |  6 ------
 net/sctp/ipv6.c              |  6 ------
 net/sctp/objcnt.c            |  6 ------
 net/sctp/output.c            |  6 ------
 net/sctp/outqueue.c          |  6 ------
 net/sctp/primitive.c         |  6 ------
 net/sctp/proc.c              |  6 ------
 net/sctp/protocol.c          |  6 ------
 net/sctp/sm_make_chunk.c     |  6 ------
 net/sctp/sm_sideeffect.c     |  6 ------
 net/sctp/sm_statefuns.c      |  6 ------
 net/sctp/sm_statetable.c     |  6 ------
 net/sctp/socket.c            |  6 ------
 net/sctp/ssnmap.c            |  6 ------
 net/sctp/sysctl.c            |  6 ------
 net/sctp/transport.c         |  6 ------
 net/sctp/tsnmap.c            |  6 ------
 net/sctp/ulpevent.c          |  6 ------
 net/sctp/ulpqueue.c          |  6 ------
 37 files changed, 8 insertions(+), 226 deletions(-)

diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
index 754c511..aa80bef 100644
--- a/include/net/sctp/auth.h
+++ b/include/net/sctp/auth.h
@@ -24,14 +24,8 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *   Vlad Yasevich     <vladislav.yasevich@hp.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #ifndef __sctp_auth_h__
diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index 483e630..259924d 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -27,9 +27,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Dinakaran Joseph
  *    Jon Grimm <jgrimm@us.ibm.com>
@@ -37,9 +34,6 @@
  *
  * Rewritten to use libcrc32c by:
  *    Vlad Yasevich <vladislav.yasevich@hp.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #ifndef __sctp_checksum_h__
diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 3524727..832f219 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -23,19 +23,17 @@
  * the Free Software Foundation, 59 Temple Place - Suite 330,
  * Boston, MA 02111-1307, USA.
  *
- * Please send any bug reports or fixes you make to one of the
- * following email addresses:
+ * Please send any bug reports or fixes you make to the
+ * email address(es):
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * La Monte H.P. Yarroll <piggy@acm.org>
- * Karl Knutson <karl@athena.chicago.il.us>
- * Ardelle Fan <ardelle.fan@intel.com>
- * Sridhar Samudrala <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
+ * Written or modified by:
+ *   La Monte H.P. Yarroll <piggy@acm.org>
+ *   Karl Knutson <karl@athena.chicago.il.us>
+ *   Ardelle Fan <ardelle.fan@intel.com>
+ *   Sridhar Samudrala <sri@us.ibm.com>
  */
 
-
 #ifndef __net_sctp_command_h__
 #define __net_sctp_command_h__
 
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index a1e7aa5..2f0a565 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -27,9 +27,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *   La Monte H.P. Yarroll <piggy@acm.org>
  *   Karl Knutson          <karl@athena.chicago.il.us>
@@ -39,9 +36,6 @@
  *   Xingang Guo           <xingang.guo@intel.com>
  *   Sridhar Samudrala     <samudrala@us.ibm.com>
  *   Daisy Chang           <daisyc@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #ifndef __sctp_constants_h__
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index cb28df9..3794c5a 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -29,9 +29,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Xingang Guo           <xingang.guo@intel.com>
@@ -41,9 +38,6 @@
  *    Ardelle Fan           <ardelle.fan@intel.com>
  *    Ryan Layer            <rmlayer@us.ibm.com>
  *    Kevin Gao             <kevin.gao@intel.com> 
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #ifndef __net_sctp_h__
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 2aa66dd..4ef75af 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -29,9 +29,6 @@
  * email addresses:
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson <karl@athena.chicago.il.us>
@@ -42,9 +39,6 @@
  *    Daisy Chang <daisyc@us.ibm.com>
  *    Ardelle Fan <ardelle.fan@intel.com>
  *    Kevin Gao <kevin.gao@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/types.h>
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 06ebeaa..78eedf0 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -27,9 +27,6 @@
  * email addresses:
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Randall Stewart	    <randall@sctp.chicago.il.us>
  *    Ken Morneau	    <kmorneau@cisco.com>
@@ -46,9 +43,6 @@
  *    Ryan Layer	    <rmlayer@us.ibm.com>
  *    Anup Pemmaiah	    <pemmaiah@cc.usu.edu>
  *    Kevin Gao             <kevin.gao@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #ifndef __sctp_structs_h__
diff --git a/include/net/sctp/tsnmap.h b/include/net/sctp/tsnmap.h
index c361d6f..54bbbe5 100644
--- a/include/net/sctp/tsnmap.h
+++ b/include/net/sctp/tsnmap.h
@@ -30,17 +30,11 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *   Jon Grimm             <jgrimm@us.ibm.com>
  *   La Monte H.P. Yarroll <piggy@acm.org>
  *   Karl Knutson          <karl@athena.chicago.il.us>
  *   Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 #include <net/sctp/constants.h>
 
diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 34f0d34..27b9f5c 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -33,17 +33,11 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *   Jon Grimm             <jgrimm@us.ibm.com>
  *   La Monte H.P. Yarroll <piggy@acm.org>
  *   Karl Knutson          <karl@athena.chicago.il.us>
  *   Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #ifndef __sctp_ulpevent_h__
diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
index add3237..b0cf5d5 100644
--- a/include/net/sctp/ulpqueue.h
+++ b/include/net/sctp/ulpqueue.h
@@ -32,16 +32,10 @@
  * email addresses:
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *   Jon Grimm             <jgrimm@us.ibm.com>
  *   La Monte H.P. Yarroll <piggy@acm.org>
  *   Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #ifndef __sctp_ulpqueue_h__
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index e425ba0..e051920 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -30,9 +30,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
@@ -43,9 +40,6 @@
  *    Daisy Chang	    <daisyc@us.ibm.com>
  *    Ryan Layer	    <rmlayer@us.ibm.com>
  *    Kevin Gao             <kevin.gao@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 3aab967..8c4fa5d 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -24,14 +24,8 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *   Vlad Yasevich     <vladislav.yasevich@hp.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/slab.h>
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index f34ce8b..077bb07 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -29,17 +29,11 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
  *    Jon Grimm             <jgrimm@us.ibm.com>
  *    Daisy Chang           <daisyc@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/types.h>
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index b50b90c..bd0bdd0 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -26,15 +26,9 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Jon Grimm             <jgrimm@us.ibm.com>
  *    Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/command.c b/net/sctp/command.c
index f4bebda..3d9a9ff 100644
--- a/net/sctp/command.c
+++ b/net/sctp/command.c
@@ -27,15 +27,9 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson <karl@athena.chicago.il.us>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/types.h>
diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index 44aa4e7..e89015d 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -30,9 +30,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
@@ -40,9 +37,6 @@
  *    Jon Grimm             <jgrimm@us.ibm.com>
  *    Daisy Chang	    <daisyc@us.ibm.com>
  *    Sridhar Samudrala	    <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <net/sctp/sctp.h>
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 825b754..09b8daa 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -31,18 +31,12 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson <karl@athena.chicago.il.us>
  *    Jon Grimm <jgrimm@austin.ibm.com>
  *    Daisy Chang <daisyc@us.ibm.com>
  *    Dajiang Zhang <dajiang.zhang@nokia.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/types.h>
diff --git a/net/sctp/input.c b/net/sctp/input.c
index b9a25e1..2873e22 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -31,9 +31,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson <karl@athena.chicago.il.us>
@@ -43,9 +40,6 @@
  *    Daisy Chang <daisyc@us.ibm.com>
  *    Sridhar Samudrala <sri@us.ibm.com>
  *    Ardelle Fan <ardelle.fan@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/types.h>
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index e70f60a..5856932 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -32,15 +32,9 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson <karl@athena.chicago.il.us>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 5a9402e..da613ce 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -29,9 +29,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Le Yanqun		    <yanqun.le@nokia.com>
  *    Hui Huang		    <hui.huang@nokia.com>
@@ -42,9 +39,6 @@
  *
  * Based on:
  *	linux/net/ipv6/tcp_ipv6.c
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index aec346c..5ea573b 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -28,14 +28,8 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Jon Grimm             <jgrimm@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/output.c b/net/sctp/output.c
index cdb5f49..e35b84c 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -28,17 +28,11 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
  *    Jon Grimm             <jgrimm@austin.ibm.com>
  *    Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 5131323..94df758 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -30,9 +30,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
@@ -41,9 +38,6 @@
  *    Hui Huang 	    <hui.huang@nokia.com>
  *    Sridhar Samudrala     <sri@us.ibm.com>
  *    Jon Grimm             <jgrimm@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/primitive.c b/net/sctp/primitive.c
index 31fa437..ce1ffd8 100644
--- a/net/sctp/primitive.c
+++ b/net/sctp/primitive.c
@@ -31,18 +31,12 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Narasimha Budihal     <narasimha@refcode.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
  *    Ardelle Fan	    <ardelle.fan@intel.com>
  *    Kevin Gao             <kevin.gao@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/types.h>
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index aff0cac..82432bf 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -24,14 +24,8 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Sridhar Samudrala <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/types.h>
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index a570a63..5448297 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -31,9 +31,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson <karl@athena.chicago.il.us>
@@ -41,9 +38,6 @@
  *    Sridhar Samudrala <sri@us.ibm.com>
  *    Daisy Chang <daisyc@us.ibm.com>
  *    Ardelle Fan <ardelle.fan@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 780a2d4..9c13133 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -31,9 +31,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
@@ -45,9 +42,6 @@
  *    Daisy Chang	    <daisyc@us.ibm.com>
  *    Ardelle Fan	    <ardelle.fan@intel.com>
  *    Kevin Gao             <kevin.gao@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index f1f3aac..666c668 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -30,9 +30,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
@@ -42,9 +39,6 @@
  *    Daisy Chang	    <daisyc@us.ibm.com>
  *    Sridhar Samudrala	    <sri@us.ibm.com>
  *    Ardelle Fan	    <ardelle.fan@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 93271f0..dfe3f36 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -30,9 +30,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
@@ -45,9 +42,6 @@
  *    Ardelle Fan	    <ardelle.fan@intel.com>
  *    Ryan Layer	    <rmlayer@us.ibm.com>
  *    Kevin Gao		    <kevin.gao@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 64ea5fd..c5999b2 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -30,9 +30,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
@@ -41,9 +38,6 @@
  *    Daisy Chang	    <daisyc@us.ibm.com>
  *    Ardelle Fan	    <ardelle.fan@intel.com>
  *    Sridhar Samudrala	    <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0245712..d5d5882 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -36,9 +36,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Narasimha Budihal     <narsi@refcode.org>
@@ -52,9 +49,6 @@
  *    Ryan Layer	    <rmlayer@us.ibm.com>
  *    Anup Pemmaiah         <pemmaiah@cc.usu.edu>
  *    Kevin Gao             <kevin.gao@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
index 72b5939..6007124 100644
--- a/net/sctp/ssnmap.c
+++ b/net/sctp/ssnmap.c
@@ -26,14 +26,8 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Jon Grimm             <jgrimm@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/types.h>
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 754809a..1b1ee76 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -27,18 +27,12 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Mingqin Liu           <liuming@us.ibm.com>
  *    Jon Grimm             <jgrimm@us.ibm.com>
  *    Ardelle Fan           <ardelle.fan@intel.com>
  *    Ryan Layer            <rmlayer@us.ibm.com>
  *    Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <net/sctp/structs.h>
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 9602c52..6836ead 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -32,9 +32,6 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Karl Knutson          <karl@athena.chicago.il.us>
@@ -43,9 +40,6 @@
  *    Hui Huang             <hui.huang@nokia.com>
  *    Sridhar Samudrala	    <sri@us.ibm.com>
  *    Ardelle Fan	    <ardelle.fan@intel.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index 0eff866..fbda200 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -29,17 +29,11 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Jon Grimm             <jgrimm@us.ibm.com>
  *    Karl Knutson          <karl@athena.chicago.il.us>
  *    Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/slab.h>
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index c07624f..81089ed 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -30,17 +30,11 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Jon Grimm             <jgrimm@us.ibm.com>
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Ardelle Fan	    <ardelle.fan@intel.com>
  *    Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/slab.h>
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 2cdb301..1c1484e 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -29,16 +29,10 @@
  * email address(es):
  *    lksctp developers <linux-sctp@vger.kernel.org>
  *
- * Or submit a bug report through the following website:
- *    http://www.sf.net/projects/lksctp
- *
  * Written or modified by:
  *    Jon Grimm             <jgrimm@us.ibm.com>
  *    La Monte H.P. Yarroll <piggy@acm.org>
  *    Sridhar Samudrala     <sri@us.ibm.com>
- *
- * Any bugs reported given to us we will try to fix... any fixes shared will
- * be incorporated into the next SCTP release.
  */
 
 #include <linux/slab.h>
-- 
1.7.11.7
