From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] NETDEV: Elecom (Laneed) LD-USBL/TX support.
Date: Wed, 25 May 2005 16:06:59 +0900 (JST)
Message-ID: <20050525.160659.60635970.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Elecom (Laneed) LD-USBL/TX support.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Index: drivers/usb/net/pegasus.h
===================================================================
--- 5b713315560487f8c288820b17061fe27016c2cc/drivers/usb/net/pegasus.h  (mode:100644)
+++ uncommitted/drivers/usb/net/pegasus.h  (mode:100644)
@@ -249,6 +249,8 @@
 		DEFAULT_GPIO_RESET)
 PEGASUS_DEV( "LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x4002,
 		DEFAULT_GPIO_RESET )
+PEGASUS_DEV( "LANEED USB Ethernet LD-USBL/TX", VENDOR_LANEED, 0x4005,
+		DEFAULT_GPIO_RESET | PEGASUS_II)
 PEGASUS_DEV( "LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x400b,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "LANEED USB Ethernet LD-USB/T", VENDOR_LANEED, 0xabc1,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
