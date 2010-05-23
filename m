From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 052/199] Documentation/isdn/INTERFACE: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:16 +0200
Message-ID: <1274644226-23612-2-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Documentation/isdn/INTERFACE:39: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:40: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:56: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:74: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:123: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:135: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:239: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:243: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:253: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:415: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:423: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:426: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:434: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:437: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:440: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:461: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:462: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:524: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:526: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:530: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:535: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:537: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:579: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:609: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:667: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:697: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:715: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:716: ERROR: trailing whitespace
Documentation/isdn/INTERFACE:726: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/INTERFACE |   58 +++++++++++++++++++++---------------------
 1 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/Documentation/isdn/INTERFACE b/Documentation/isdn/INTERFACE
index 5df17e5..5054867 100644
--- a/Documentation/isdn/INTERFACE
+++ b/Documentation/isdn/INTERFACE
@@ -36,8 +36,8 @@ Description of the Interface between Linklevel and Hardwarelevel
   Changes in this document are marked with '***CHANGEx' where x representing
   the version number. If that number starts with 0, it refers to the old,
   separately distributed package. If it starts with one of the letters
-  above, it refers to the revision of the corresponding module. 
-  ***CHANGEIx refers to the revision number of the isdnif.h  
+  above, it refers to the revision of the corresponding module.
+  ***CHANGEIx refers to the revision number of the isdnif.h
 
 1. Description of the fields of isdn_if:
 
@@ -53,7 +53,7 @@ Description of the Interface between Linklevel and Hardwarelevel
     ***CHANGE0.6: New since this version.
 
     Also to be preset by the HL-driver. With this value the HL-driver
-    tells the LL the maximum size of a data-packet it will accept. 
+    tells the LL the maximum size of a data-packet it will accept.
 
   unsigned long features;
 
@@ -71,7 +71,7 @@ Description of the Interface between Linklevel and Hardwarelevel
 
     To be preset by the HL-driver, if it supports sk_buff's. The driver
     should put here the amount of additional space needed in sk_buff's for
-    its internal purposes. Drivers not supporting sk_buff's should 
+    its internal purposes. Drivers not supporting sk_buff's should
     initialize this field to 0.
 
   void (*rcvcallb_skb)(int, int, struct sk_buff *)
@@ -120,7 +120,7 @@ Description of the Interface between Linklevel and Hardwarelevel
         command = command to perform. (one of the constants ISDN_CMD_...)
         arg     = depends on command.
         num     = depends on command.
-    
+
     Returnvalue:
       >=0 on success, else error-code (-ENODEV etc.)
 
@@ -132,7 +132,7 @@ Description of the Interface between Linklevel and Hardwarelevel
     This field has to be preset by the HL-driver. The given function will
     be called by the LL for delivering data to be send via B-Channel.
 
- 
+
     Parameter:
       int              driver-Id ***CHANGE0.7.4: New parameter.
       int              channel-number locally to the HL-driver. (starts with 0)
@@ -236,11 +236,11 @@ Description of the Interface between Linklevel and Hardwarelevel
        command  = ISDN_CMD_IOCTL
        arg      = Original ioctl-cmd - IIOCDRVCTL
        parm.num = first bytes filled with (unsigned long)arg
-   
+
      Returnvalue:
        Depending on driver.
 
-  
+
   ISDN_CMD_DIAL:
 
     This command is used to tell the HL-driver it should dial a given
@@ -250,7 +250,7 @@ Description of the Interface between Linklevel and Hardwarelevel
       driver      = driver-Id.
       command     = ISDN_CMD_DIAL
       arg         = channel-number locally to the driver. (starting with 0)
-      
+
       parm.setup.phone  = An ASCII-String containing the number to dial.
       parm.setup.eazmsn = An ASCII-Sting containing the own EAZ or MSN.
       parm.setup.si1    = The Service-Indicator.
@@ -412,7 +412,7 @@ Description of the Interface between Linklevel and Hardwarelevel
     Returnvalue:
       current protocol-Id (one of the constants ISDN_L3_PROTO)
 
-  ISDN_CMD_PROCEED: 
+  ISDN_CMD_PROCEED:
 
     With this command, the HL-driver is told to proceed with a incoming call.
 
@@ -420,10 +420,10 @@ Description of the Interface between Linklevel and Hardwarelevel
       driver      = driver-Id.
       command     = ISDN_CMD_PROCEED
       arg         = channel-number locally to the driver. (starting with 0)
-      setup.eazmsn= empty string or string send as uus1 in DSS1 with 
+      setup.eazmsn= empty string or string send as uus1 in DSS1 with
                     PROCEED message
 
-  ISDN_CMD_ALERT: 
+  ISDN_CMD_ALERT:
 
     With this command, the HL-driver is told to alert a proceeding call.
 
@@ -431,13 +431,13 @@ Description of the Interface between Linklevel and Hardwarelevel
       driver      = driver-Id.
       command     = ISDN_CMD_ALERT
       arg         = channel-number locally to the driver. (starting with 0)
-      setup.eazmsn= empty string or string send as uus1 in DSS1 with 
+      setup.eazmsn= empty string or string send as uus1 in DSS1 with
                     ALERT message
 
-  ISDN_CMD_REDIR: 
+  ISDN_CMD_REDIR:
 
     With this command, the HL-driver is told to redirect a call in proceeding
-    or alerting state.  
+    or alerting state.
 
     Parameter:
       driver      = driver-Id.
@@ -458,8 +458,8 @@ Description of the Interface between Linklevel and Hardwarelevel
       command     = ISDN_CMD_PROT_IO
       arg         = The lower 8 Bits define the addressed protocol as defined
                     in ISDN_PTYPE..., the upper bits are used to differentiate
-                    the protocol specific CMD.  
-      
+                    the protocol specific CMD.
+
       para        = protocol and function specific. See isdnif.h for detail.
 
 
@@ -521,20 +521,20 @@ Description of the Interface between Linklevel and Hardwarelevel
                     HL-driver may send ALERTING on the D-channel in this case.
       2           = Call will be rejected.
       3           = Incoming called party number is currently incomplete.
-                    Additional digits are required. 
+                    Additional digits are required.
                     Used for signalling with PtP connections.
-      4	          = Call will be held in a proceeding state 
+      4	          = Call will be held in a proceeding state
                     (HL driver sends PROCEEDING)
                     Used when a user space prog needs time to interpret a call
 		    para.setup.eazmsn may be filled with an uus1 message of
-		    30 octets maximum. Empty string if no uus. 
+		    30 octets maximum. Empty string if no uus.
       5           = Call will be actively deflected to another party
                     Only available in DSS1/EURO protocol
 		    para.setup.phone must be set to destination party number
 		    para.setup.eazmsn may be filled with an uus1 message of
-		    30 octets maximum. Empty string if no uus. 
+		    30 octets maximum. Empty string if no uus.
       -1          = An error happened. (Invalid parameters for example.)
-  The keypad support now is included in the dial command.	        
+  The keypad support now is included in the dial command.
 
 
   ISDN_STAT_RUN:
@@ -576,7 +576,7 @@ Description of the Interface between Linklevel and Hardwarelevel
    a B-Channel-connection. (Response to ISDN_CMD_ACCEPTB or because the
    remote-station has initiated establishment)
 
-   The HL driver should call this when the logical l2/l3 protocol 
+   The HL driver should call this when the logical l2/l3 protocol
    connection on top of the physical B-channel is established.
 
     Parameter:
@@ -606,7 +606,7 @@ Description of the Interface between Linklevel and Hardwarelevel
    B-Channel-connection. This could be a response to a prior ISDN_CMD_HANGUP,
    or caused by a remote-hangup.
 
-   The HL driver should call this as soon as the logical l2/l3 protocol 
+   The HL driver should call this as soon as the logical l2/l3 protocol
    connection on top of the physical B-channel is released.
 
     Parameter:
@@ -664,7 +664,7 @@ Description of the Interface between Linklevel and Hardwarelevel
       arg         = channel-number, locally to the driver. (starting with 0)
       parm        = unused.
 
-  ISDN_STAT_ADDCH: 
+  ISDN_STAT_ADDCH:
 
     This call is for HL-drivers, which are unable to check card-type
     or numbers of supported channels before they have loaded any firmware
@@ -694,7 +694,7 @@ Description of the Interface between Linklevel and Hardwarelevel
   ISDN_STAT_DISPLAY:
 
     With this call, the HL-driver delivers DISPLAY-messages to the LL.
-    Currently the LL does not use this messages. 
+    Currently the LL does not use this messages.
 
     Parameter:
       driver      = driver-Id
@@ -712,8 +712,8 @@ Description of the Interface between Linklevel and Hardwarelevel
       command     = ISDN_STAT_PROT
       arg         = The lower 8 Bits define the addressed protocol as defined
                     in ISDN_PTYPE..., the upper bits are used to differentiate
-                    the protocol specific STAT.  
-      
+                    the protocol specific STAT.
+
       para        = protocol and function specific. See isdnif.h for detail.
 
   ISDN_STAT_DISCH:
@@ -723,7 +723,7 @@ Description of the Interface between Linklevel and Hardwarelevel
     The call may be used to reduce the available number of B-channels after
     loading the driver. The LL has to ignore a disabled channel when searching
     for free channels. The HL driver itself never delivers STAT callbacks for
-    disabled channels. 	    
+    disabled channels.
     The LL returns a nonzero code if the operation was not successful or the
     selected channel is actually regarded as busy.
 
-- 
1.7.1.251.gf80a2

