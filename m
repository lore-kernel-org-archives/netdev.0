From: David Miller <davem@davemloft.net>
Subject: myri10ge net-2.6.24 build fix
Date: Thu, 09 Aug 2007 00:11:38 -0700 (PDT)
Message-ID: <20070809.001138.39464000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44817
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751599AbXHIHLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 03:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I had to add the following patch to fix the build after
the LRO changes, I have no idea how you could have compile
tested that patch let alone done any real testing on it :-/

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 4cc5e6f..0ac0610 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -93,6 +93,7 @@ MODULE_LICENSE("Dual BSD/GPL");
 #define MYRI10GE_EEPROM_STRINGS_SIZE 256
 #define MYRI10GE_MAX_SEND_DESC_TSO ((65536 / 2048) * 2)
 #define MYRI10GE_MAX_LRO_DESCRIPTORS 8
+#define MYRI10GE_LRO_MAX_PKTS 64
 
 #define MYRI10GE_NO_CONFIRM_DATA htonl(0xffffffff)
 #define MYRI10GE_NO_RESPONSE_RESULT 0xffffffff
