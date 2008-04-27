From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6/stable] [XFRM] AUDIT: Fix flowlabel text format.
Date: Sun, 27 Apr 2008 12:24:18 +0900 (JST)
Message-ID: <20080427.122418.32604330.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33806 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761508AbYD0DYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 23:24:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5dcc10b..fac27ce 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2112,7 +2112,7 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 		iph6 = ipv6_hdr(skb);
 		audit_log_format(audit_buf,
 				 " src=" NIP6_FMT " dst=" NIP6_FMT
-				 " flowlbl=0x%x%x%x",
+				 " flowlbl=0x%x%02x%02x",
 				 NIP6(iph6->saddr),
 				 NIP6(iph6->daddr),
 				 iph6->flow_lbl[0] & 0x0f,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
