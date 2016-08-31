From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 5/8] fou: make nla_policy const
Date: Wed, 31 Aug 2016 15:19:37 -0700
Message-ID: <20160831151937.19477e85@xeon-e3>
References: <20160831151445.6c8e4e06@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35811 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbcIAGZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:25:13 -0400
Received: by mail-pf0-f174.google.com with SMTP id x72so27871061pfd.2
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 23:25:12 -0700 (PDT)
In-Reply-To: <20160831151445.6c8e4e06@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ipv4/fou.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 321d57f..cf50f7e 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -631,7 +631,7 @@ static struct genl_family fou_nl_family = {
 	.netnsok	= true,
 };
 
-static struct nla_policy fou_nl_policy[FOU_ATTR_MAX + 1] = {
+static const struct nla_policy fou_nl_policy[FOU_ATTR_MAX + 1] = {
 	[FOU_ATTR_PORT] = { .type = NLA_U16, },
 	[FOU_ATTR_AF] = { .type = NLA_U8, },
 	[FOU_ATTR_IPPROTO] = { .type = NLA_U8, },
-- 
2.9.3
