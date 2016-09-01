From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 8/8] l2tp: make nla_policy const
Date: Wed, 31 Aug 2016 23:24:41 -0700
Message-ID: <20160831232441.6da35a0b@xeon-e3>
References: <20160831152200.72ca2ac1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33592 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751907AbcIAGZS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:25:18 -0400
Received: by mail-pa0-f54.google.com with SMTP id cy9so26563921pac.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 23:25:18 -0700 (PDT)
In-Reply-To: <20160831152200.72ca2ac1@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/l2tp/l2tp_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 1d02e8d..bf31177 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -867,7 +867,7 @@ out:
 	return skb->len;
 }
 
-static struct nla_policy l2tp_nl_policy[L2TP_ATTR_MAX + 1] = {
+static const struct nla_policy l2tp_nl_policy[L2TP_ATTR_MAX + 1] = {
 	[L2TP_ATTR_NONE]		= { .type = NLA_UNSPEC, },
 	[L2TP_ATTR_PW_TYPE]		= { .type = NLA_U16, },
 	[L2TP_ATTR_ENCAP_TYPE]		= { .type = NLA_U16, },
-- 
2.9.3
