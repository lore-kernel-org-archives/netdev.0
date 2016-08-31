From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/8] ila: make nla_policy const
Date: Wed, 31 Aug 2016 15:20:51 -0700
Message-ID: <20160831152051.452741cd@xeon-e3>
References: <20160831151445.6c8e4e06@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32920 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbcIAGZO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:25:14 -0400
Received: by mail-pf0-f169.google.com with SMTP id g202so4757934pfb.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 23:25:14 -0700 (PDT)
In-Reply-To: <20160831151445.6c8e4e06@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ipv6/ila/ila_lwt.c  | 2 +-
 net/ipv6/ila/ila_xlat.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index c8314c6..e50c27a 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -51,7 +51,7 @@ drop:
 	return -EINVAL;
 }
 
-static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
+static const struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
 	[ILA_ATTR_CSUM_MODE] = { .type = NLA_U8, },
 };
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index e6eca5f..e604013 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -128,7 +128,7 @@ static struct genl_family ila_nl_family = {
 	.parallel_ops	= true,
 };
 
-static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
+static const struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
 	[ILA_ATTR_LOCATOR_MATCH] = { .type = NLA_U64, },
 	[ILA_ATTR_IFINDEX] = { .type = NLA_U32, },
-- 
2.9.3
