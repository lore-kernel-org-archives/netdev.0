From: Joe Perches <joe@perches.com>
Subject: [PATCH 52/59] net/ipv4: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:39 -0800
Message-ID: <f047768599df11a74301f81e61903c87417ea9e4.1195454436.git.joe__43491.5673490197$1195524713$gmane$org@perches.com>
References: 1234567
 <1195523627-15389-1-git-send-email-joe@perches.com>
 <1195523627-15389-2-git-send-email-joe@perches.com>
 <1195523627-15389-3-git-send-email-joe@perches.com>
 <1195523627-15389-4-git-send-email-joe@perches.com>
 <1195523627-15389-5-git-send-email-joe@perches.com>
 <1195523627-15389-6-git-send-email-joe@perches.com>
 <1195523627-15389-7-git-send-email-joe@perches.com>
 <1195523627-15389-8-git-send-email-joe@perches.com>
 <1195523627-15389-9-git-send-email-joe@perches.com>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Networking Team <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757666AbXKTCJn@vger.kernel.org>
In-Reply-To: <1195523627-15389-9-git-send-email-joe@perches.com>
Message-Id: <f047768599df11a74301f81e61903c87417ea9e4.1195454436.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/ipvs/ip_vs_core.c       |    2 +-
 net/ipv4/netfilter/iptable_raw.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 20c884a..8fba202 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -637,7 +637,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 	verdict = NF_DROP;
 
 	if (IP_VS_FWD_METHOD(cp) != 0) {
-		IP_VS_ERR("shouldn't reach here, because the box is on the"
+		IP_VS_ERR("shouldn't reach here, because the box is on the "
 			  "half connection in the tun/dr module.\n");
 	}
 
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 5de6e57..f867865 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -66,7 +66,7 @@ ipt_local_hook(unsigned int hook,
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
-			printk("iptable_raw: ignoring short SOCK_RAW"
+			printk("iptable_raw: ignoring short SOCK_RAW "
 			       "packet.\n");
 		return NF_ACCEPT;
 	}
-- 
1.5.3.5.652.gf192c
