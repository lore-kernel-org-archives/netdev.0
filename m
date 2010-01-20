From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 1/2] conntrack: delete the redundant macro definitions
Date: Wed, 20 Jan 2010 14:20:41 +0800
Message-ID: <4B56A0B9.7020406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	yasuyuki.kozakai@toshiba.co.jp
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following three macro definitions are never used, so delete them.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 312c20a..1030ce1 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -45,9 +45,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 
-#define NF_CT_FRAG6_HIGH_THRESH 262144 /* == 256*1024 */
-#define NF_CT_FRAG6_LOW_THRESH 196608  /* == 192*1024 */
-#define NF_CT_FRAG6_TIMEOUT IPV6_FRAG_TIMEOUT
 
 struct nf_ct_frag6_skb_cb
 {
-- 
1.6.3.3


