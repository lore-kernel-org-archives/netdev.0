From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/04: add missing linux/types.h include to xt_LED.h
Date: Tue,  5 May 2009 18:47:44 +0200 (MEST)
Message-ID: <20090505164743.19290.67296.sendpatchset@x2.localnet>
References: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a7ca7fccacc029958fd09985e7f3529b90ec791d
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue May 5 14:31:12 2009 +0200

    netfilter: add missing linux/types.h include to xt_LED.h
    
    Pointed out by Dave Miller:
    
      CHECK   include/linux/netfilter (57 files)
    /home/davem/src/GIT/net-2.6/usr/include/linux/netfilter/xt_LED.h:6: found __[us]{8,16,32,64} type without #include <linux/types.h>
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/xt_LED.h b/include/linux/netfilter/xt_LED.h
index 4c91a0d..f5509e7 100644
--- a/include/linux/netfilter/xt_LED.h
+++ b/include/linux/netfilter/xt_LED.h
@@ -1,6 +1,8 @@
 #ifndef _XT_LED_H
 #define _XT_LED_H
 
+#include <linux/types.h>
+
 struct xt_led_info {
 	char id[27];        /* Unique ID for this trigger in the LED class */
 	__u8 always_blink;  /* Blink even if the LED is already on */
