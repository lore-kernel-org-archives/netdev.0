From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/7] flow_dissector: make local function static
Date: Tue, 10 Jan 2017 10:18:10 -0800
Message-ID: <20170110181816.18991-2-sthemmin@microsoft.com>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32877 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939964AbdAJSS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:18:27 -0500
Received: by mail-pf0-f173.google.com with SMTP id y143so29963328pfb.0
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:18:26 -0800 (PST)
In-Reply-To: <20170110181816.18991-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warning: no previous prototype for ‘skb_flow_get_be16’
Function is only used in this file, make it static.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/flow_dissector.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index fe4e1531976c..1b7673aac59d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -67,8 +67,8 @@ EXPORT_SYMBOL(skb_flow_dissector_init);
  * The function will try to retrieve a be32 entity at
  * offset poff
  */
-__be16 skb_flow_get_be16(const struct sk_buff *skb, int poff, void *data,
-			 int hlen)
+static __be16 skb_flow_get_be16(const struct sk_buff *skb, int poff,
+				void *data, int hlen)
 {
 	__be16 *u, _u;
 
-- 
2.11.0
