From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 7/6] ipv6: Add missing newline to __xfrm6_output_finish
Date: Thu, 01 Oct 2015 11:44:08 -0500
Message-ID: <87y4fm8ron.fsf_-_@x220.int.ebiederm.org>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
	<1443648336-31741-4-git-send-email-ebiederm@xmission.com>
	<560CEF6F.4030403@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <560CEF6F.4030403@6wind.com> (Nicolas Dichtel's message of "Thu,
	1 Oct 2015 10:31:43 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add a newline between variable declarations and the code.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv6/xfrm6_output.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 335066a64b45..4cefda009f53 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -134,6 +134,7 @@ int xfrm6_output_finish(struct sock *sk, struct sk_buff *skb)
 static int __xfrm6_output_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct xfrm_state *x = skb_dst(skb)->xfrm;
+
 	return x->outer_mode->afinfo->output_finish(sk, skb);
 }
 
-- 
2.2.1

