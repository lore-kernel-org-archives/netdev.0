From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2] IPV6: Don't change indexes depends on configuration
Date: Thu, 15 Jan 2004 21:46:45 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115.214645.54863143.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

The DEVCONF_xxx are part of kernel - user interface.
It should have been constant even if the kernel config changed.

This patch depends on the "[PATCH] IPV6: added sysctl for maximum number 
of addresses" patch.

Thanks.

--- linux26+maxaddresses/include/linux/ipv6.h	Thu Jan 15 21:38:08 2004
+++ linux26+maxaddresses+devconf/include/linux/ipv6.h	Thu Jan 15 21:38:17 2004
@@ -159,13 +159,11 @@
 	DEVCONF_RTR_SOLICITS,
 	DEVCONF_RTR_SOLICIT_INTERVAL,
 	DEVCONF_RTR_SOLICIT_DELAY,
-#ifdef CONFIG_IPV6_PRIVACY
 	DEVCONF_USE_TEMPADDR,
 	DEVCONF_TEMP_VALID_LFT,
 	DEVCONF_TEMP_PREFERED_LFT,
 	DEVCONF_REGEN_MAX_RETRY,
 	DEVCONF_MAX_DESYNC_FACTOR,
-#endif
 	DEVCONF_MAX_ADDRESSES,
 	DEVCONF_MAX
 };


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
