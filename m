From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 057/199] Documentation/isdn/README.diversion: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:21 +0200
Message-ID: <1274644226-23612-7-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Documentation/isdn/README.diversion:2: ERROR: trailing whitespace
Documentation/isdn/README.diversion:3: ERROR: trailing whitespace
Documentation/isdn/README.diversion:4: ERROR: trailing whitespace
Documentation/isdn/README.diversion:5: ERROR: trailing whitespace
Documentation/isdn/README.diversion:28: ERROR: trailing whitespace
Documentation/isdn/README.diversion:33: ERROR: trailing whitespace
Documentation/isdn/README.diversion:34: ERROR: trailing whitespace
Documentation/isdn/README.diversion:37: ERROR: trailing whitespace
Documentation/isdn/README.diversion:39: ERROR: trailing whitespace
Documentation/isdn/README.diversion:41: ERROR: trailing whitespace
Documentation/isdn/README.diversion:44: ERROR: trailing whitespace
Documentation/isdn/README.diversion:45: ERROR: trailing whitespace
Documentation/isdn/README.diversion:46: ERROR: trailing whitespace
Documentation/isdn/README.diversion:47: ERROR: trailing whitespace
Documentation/isdn/README.diversion:50: ERROR: trailing whitespace
Documentation/isdn/README.diversion:51: ERROR: trailing whitespace
Documentation/isdn/README.diversion:60: ERROR: trailing whitespace
Documentation/isdn/README.diversion:64: ERROR: trailing whitespace
Documentation/isdn/README.diversion:70: ERROR: trailing whitespace
Documentation/isdn/README.diversion:71: ERROR: trailing whitespace
Documentation/isdn/README.diversion:74: ERROR: trailing whitespace
Documentation/isdn/README.diversion:76: ERROR: trailing whitespace
Documentation/isdn/README.diversion:80: ERROR: trailing whitespace
Documentation/isdn/README.diversion:82: ERROR: trailing whitespace
Documentation/isdn/README.diversion:89: ERROR: trailing whitespace
Documentation/isdn/README.diversion:91: ERROR: trailing whitespace
Documentation/isdn/README.diversion:92: ERROR: trailing whitespace
Documentation/isdn/README.diversion:95: ERROR: trailing whitespace
Documentation/isdn/README.diversion:96: ERROR: trailing whitespace
Documentation/isdn/README.diversion:104: ERROR: trailing whitespace
Documentation/isdn/README.diversion:105: ERROR: trailing whitespace
Documentation/isdn/README.diversion:111: ERROR: trailing whitespace
Documentation/isdn/README.diversion:114: ERROR: trailing whitespace
Documentation/isdn/README.diversion:116: ERROR: trailing whitespace
Documentation/isdn/README.diversion:117: ERROR: trailing whitespace
Documentation/isdn/README.diversion:118: ERROR: trailing whitespace
Documentation/isdn/README.diversion:120: ERROR: trailing whitespace
Documentation/isdn/README.diversion:122: ERROR: trailing whitespace
Documentation/isdn/README.diversion:125: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/README.diversion |   78 +++++++++++++++++-----------------
 1 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/Documentation/isdn/README.diversion b/Documentation/isdn/README.diversion
index bddcd5f..24b2647 100644
--- a/Documentation/isdn/README.diversion
+++ b/Documentation/isdn/README.diversion
@@ -1,8 +1,8 @@
 The isdn diversion services are a supporting module working together with
-the isdn4linux and the HiSax module for passive cards. 
-Active cards, TAs and cards using a own or other driver than the HiSax 
-module need to be adapted to the HL<->LL interface described in a separate 
-document. The diversion services may be used with all cards supported by 
+the isdn4linux and the HiSax module for passive cards.
+Active cards, TAs and cards using a own or other driver than the HiSax
+module need to be adapted to the HL<->LL interface described in a separate
+document. The diversion services may be used with all cards supported by
 the HiSax driver.
 The diversion kernel interface and controlling tool divertctrl were written
 by Werner Cornelius (werner@isdn4linux.de or werner@titro.de) under the
@@ -25,30 +25,30 @@ GNU General Public License.
 Table of contents
 =================
 
-1. Features of the i4l diversion services 
+1. Features of the i4l diversion services
    (Or what can the i4l diversion services do for me)
 
 2. Required hard- and software
 
-3. Compiling, installing and loading/unloading the module  
-   Tracing calling and diversion information 
+3. Compiling, installing and loading/unloading the module
+   Tracing calling and diversion information
 
 4. Tracing calling and diversion information
- 
+
 5. Format of the divert device ASCII output
- 
 
-1. Features of the i4l diversion services 
+
+1. Features of the i4l diversion services
    (Or what can the i4l diversion services do for me)
 
-   The i4l diversion services offers call forwarding and logging normally 
-   only supported by isdn phones. Incoming calls may be diverted 
-   unconditionally (CFU), when not reachable (CFNR) or on busy condition 
-   (CFB). 
+   The i4l diversion services offers call forwarding and logging normally
+   only supported by isdn phones. Incoming calls may be diverted
+   unconditionally (CFU), when not reachable (CFNR) or on busy condition
+   (CFB).
    The diversions may be invoked statically in the providers exchange
    as normally done by isdn phones. In this case all incoming calls
-   with a special (or all) service identifiers are forwarded if the 
-   forwarding reason is met. Activated static services may also be 
+   with a special (or all) service identifiers are forwarded if the
+   forwarding reason is met. Activated static services may also be
    interrogated (queried).
    The i4l diversion services additionally offers a dynamic version of
    call forwarding which is not preprogrammed inside the providers exchange
@@ -57,43 +57,43 @@ Table of contents
    compared to the mechanism of ipfwadm or ipchains. If a given rule matches
    the checking process is finished and the rule matching will be applied
    to the call.
-   The rules include primary and secondary service identifiers, called 
+   The rules include primary and secondary service identifiers, called
    number and subaddress, callers number and subaddress and whether the rule
    matches to all filtered calls or only those when all B-channel resources
    are exhausted.
-   Actions that may be invoked by a rule are ignore, proceed, reject, 
+   Actions that may be invoked by a rule are ignore, proceed, reject,
    direct divert or delayed divert of a call.
    All incoming calls matching a rule except the ignore rule a reported and
    logged as ASCII via the proc filesystem (/proc/net/isdn/divert). If proceed
    is selected the call will be held in a proceeding state (without ringing)
    for a certain amount of time to let an external program or client decide
-   how to handle the call. 
-            
+   how to handle the call.
+
 
 2. Required hard- and software
-   
+
    For using the i4l diversion services the isdn line must be of a EURO/DSS1
-   type. Additionally the i4l services only work together with the HiSax 
+   type. Additionally the i4l services only work together with the HiSax
    driver for passive isdn cards. All HiSax supported cards may be used for
    the diversion purposes.
    The static diversion services require the provider having static services
-   CFU, CFNR, CFB activated on an MSN-line. The static services may not be 
+   CFU, CFNR, CFB activated on an MSN-line. The static services may not be
    used on a point-to-point connection. Further the static services are only
-   available in some countries (for example germany). Countries requiring the 
+   available in some countries (for example germany). Countries requiring the
    keypad protocol for activating static diversions (like the netherlands) are
    not supported but may use the tty devices for this purpose.
    The dynamic diversion services may be used in all countries if the provider
    enables the feature CF (call forwarding). This should work on both MSN- and
    point-to-point lines.
    To add and delete rules the additional divertctrl program is needed. This
-   program is part of the isdn4kutils package.   
+   program is part of the isdn4kutils package.
 
-3. Compiling, installing and loading/unloading the module  
-   Tracing calling and diversion information 
+3. Compiling, installing and loading/unloading the module
+   Tracing calling and diversion information
 
 
-   To compile the i4l code with diversion support you need to say yes to the 
-   DSS1 diversion services when selecting the i4l options in the kernel 
+   To compile the i4l code with diversion support you need to say yes to the
+   DSS1 diversion services when selecting the i4l options in the kernel
    config (menuconfig or config).
    After having properly activated a make modules and make modules_install all
    required modules will be correctly installed in the needed modules dirs.
@@ -101,27 +101,27 @@ Table of contents
    standard distributions you will have to add a "insmod dss1_divert" after
    having loaded the global isdn module.
    The module can be loaded without any command line parameters.
-   If the module is actually loaded and active may be checked with a 
-   "cat /proc/modules" or "ls /proc/net/isdn/divert". The divert file is 
+   If the module is actually loaded and active may be checked with a
+   "cat /proc/modules" or "ls /proc/net/isdn/divert". The divert file is
    dynamically created by the diversion module and removed when the module is
    unloaded.
 
 
 4. Tracing calling and diversion information
- 
+
    You also may put a "cat /proc/net/isdn/divert" in the background with the
    output redirected to a file. Then all actions of the module are logged.
-   The divert file in the proc system may be opened more than once, so in 
+   The divert file in the proc system may be opened more than once, so in
    conjunction with inetd and a small remote client on other machines inside
-   your network incoming calls and reactions by the module may be shown on 
-   every listening machine. 
-   If a call is reported as proceeding an external program or client may 
+   your network incoming calls and reactions by the module may be shown on
+   every listening machine.
+   If a call is reported as proceeding an external program or client may
    specify during a certain amount of time (normally 4 to 10 seconds) what
-   to do with that call.      
+   to do with that call.
    To unload the module all open files to the device in the proc system must
-   be closed. Otherwise the module (and isdn.o) may not be unloaded. 
+   be closed. Otherwise the module (and isdn.o) may not be unloaded.
 
 5. Format of the divert device ASCII output
- 
+
    To be done later
 
-- 
1.7.1.251.gf80a2

