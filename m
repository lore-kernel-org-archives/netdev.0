From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [IPV6] ADDRCONF: Fix conflicts in DEVCONF_xxx constant.
Date: Mon, 21 May 2007 12:33:37 +0900 (JST)
Message-ID: <20070521.123337.36076825.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37789 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbXEUDdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2007 23:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 09ea01a..648bd1f 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -209,9 +209,8 @@ enum {
 	DEVCONF_RTR_PROBE_INTERVAL,
 	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
 	DEVCONF_PROXY_NDP,
-	__DEVCONF_OPTIMISTIC_DAD,
-	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_OPTIMISTIC_DAD,
+	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_MAX
 };
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
