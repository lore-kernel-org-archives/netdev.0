From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCHv1 net-next 3/5] netlink: mmap: fix status for not delivered
 skb
Date: Wed, 12 Aug 2015 17:34:19 +0900
Message-ID: <20150812083419.GD13385@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32928 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933821AbbHLIeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 04:34:24 -0400
Received: by pabyb7 with SMTP id yb7so9936970pab.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 01:34:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150812082824.GA13385@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 45c8502..c03fad0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -864,7 +864,7 @@ static void netlink_skb_destructor(struct sk_buff *skb)
 		} else {
 			if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
 				hdr->nm_len = 0;
-				netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
+				netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
 			}
 			ring = &nlk_sk(sk)->rx_ring;
 		}
-- 
1.7.10.4
