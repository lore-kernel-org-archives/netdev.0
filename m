From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 062/199] Documentation/isdn/README.x25: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:25 +0200
Message-ID: <1274644226-23612-11-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Documentation/isdn/README.x25:1: ERROR: trailing whitespace
Documentation/isdn/README.x25:25: ERROR: trailing whitespace
Documentation/isdn/README.x25:26: ERROR: trailing whitespace
Documentation/isdn/README.x25:31: ERROR: trailing whitespace
Documentation/isdn/README.x25:33: ERROR: trailing whitespace
Documentation/isdn/README.x25:75: ERROR: trailing whitespace
Documentation/isdn/README.x25:143: ERROR: trailing whitespace
Documentation/isdn/README.x25:152: ERROR: trailing whitespace
Documentation/isdn/README.x25:162: ERROR: trailing whitespace
Documentation/isdn/README.x25:182: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/README.x25 |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/Documentation/isdn/README.x25 b/Documentation/isdn/README.x25
index e561a77..c6fe709 100644
--- a/Documentation/isdn/README.x25
+++ b/Documentation/isdn/README.x25
@@ -1,4 +1,3 @@
-  
 X.25 support within isdn4linux
 ==============================
 
@@ -22,15 +21,15 @@ more bugs as usual.
 
 - Monitor your isdn connections while using this software. This should
   prevent you from undesired phone bills in case of driver problems.
-  
- 
+
+
 
 
 How to configure the kernel
 ===========================
- 
+
 The ITU-T (former CCITT) X.25 network protocol layer has been implemented
-in the Linux source tree since version 2.1.16. The isdn subsystem might be 
+in the Linux source tree since version 2.1.16. The isdn subsystem might be
 useful to run X.25 on top of ISDN. If you want to try it, select
 
    "CCITT X.25 Packet Layer"
@@ -72,7 +71,7 @@ X.25 on top of isdn might be useful with two different scenarios:
   also allows using the D-channel) is not supported by isdn4linux.
   It should however be possible to establish such packet mode connections
   with certain active isdn cards provided that the firmware supports X.31
-  and the driver exports this functionality to the user. Currently, 
+  and the driver exports this functionality to the user. Currently,
   the AVM B1 driver is the only driver which does so. (It should be
   possible to access D-channel X.31 with active AVM cards using the
   CAPI interface of the AVM-B1 driver).
@@ -140,7 +139,7 @@ To test X.25 on top of isdn, you need to get
 - a recent version of the "isdnctrl" program that supports setting the new
   X.25 specific parameters.
 
-- the x25-utils-2.X package from 
+- the x25-utils-2.X package from
   ftp://ftp.hes.iki.fi/pub/ham/linux/ax25/x25utils-*
   (don't confuse the x25-utils with the ax25-utils)
 
@@ -149,7 +148,7 @@ To test X.25 on top of isdn, you need to get
 
 Before compiling the user level utilities make sure that the compiler/
 preprocessor will fetch the proper kernel header files of this kernel
-source tree. Either make /usr/include/linux a symbolic link pointing to 
+source tree. Either make /usr/include/linux a symbolic link pointing to
 this kernel's include/linux directory or set the appropriate compiler flags.
 
 When all drivers and interfaces are loaded and configured you need to
@@ -159,7 +158,7 @@ the usual ifconfig tool.
 ifconfig <iface-name> up
 
 But a special x25route tool (distributed with the x25-util package)
-is needed to set up X.25 routes. I.e. 
+is needed to set up X.25 routes. I.e.
 
 x25route add 01 <iface-name>
 
@@ -179,6 +178,6 @@ provide useful examples for setting up X.25 on top of isdn.
 
 The x25-utility package also contains an x25trace tool that can be
 used to monitor X.25 packets received by the network interfaces.
-The /proc/net/x25* files also contain useful information. 
+The /proc/net/x25* files also contain useful information.
 
 - Henner
-- 
1.7.1.251.gf80a2

