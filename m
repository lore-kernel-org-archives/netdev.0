From: Pavlin Radoslavov <pavlin@icir.org>
Subject: A request to add RTPROT_XORP to linux/rtnetlink.h
Date: Tue, 02 Dec 2003 13:19:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312022119.hB2LJaSx017575@possum.icir.org>
Cc: pavlin@icir.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[If this is not the right mailing list for such request, please let
 me know where I should send it to.]

On behalf of the XORP (eXtensible Open Router Platform) project
(http://www.xorp.org), I'd like to ask if the XORP-specific protocol
value can be included in linux/rtnetlink.h (similar to the values
already assigned to other routing daemons/suites such as GateD,
etc.)

Below I am including the simple one-line patch against
linux-2.6.0-test11.

Any chance this can be added to 2.6.0 before its release? :)

Thanks,
Pavlin


--- linux-2.6.0-test11/include/linux/rtnetlink.h.org	Wed Nov 26 12:45:11 2003
+++ linux-2.6.0-test11/include/linux/rtnetlink.h	Tue Dec  2 12:53:18 2003
@@ -138,6 +138,7 @@
 #define RTPROT_ZEBRA	11	/* Zebra */
 #define RTPROT_BIRD	12	/* BIRD */
 #define RTPROT_DNROUTED	13	/* DECnet routing daemon */
+#define RTPROT_XORP	14	/* XORP */
 
 /* rtm_scope
 
