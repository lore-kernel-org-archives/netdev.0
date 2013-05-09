From: Denis Efremov <yefremov.denis@gmail.com>
Subject: [PATCH 11/21] ipv4: ip_output: remove inline marking of EXPORT_SYMBOL functions
Date: Thu,  9 May 2013 13:19:42 +0400
Message-ID: <1368091192-10245-6-git-send-email-yefremov.denis@gmail.com>
References: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
Cc: Denis Efremov <yefremov.denis@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org,
	ldv-project@linuxtesting.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EXPORT_SYMBOL and inline directives are contradictory to each other.
The patch fixes this inconsistency.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Denis Efremov <yefremov.denis@gmail.com>
---
 net/ipv4/ip_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 147abf5..4bcabf3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -84,7 +84,7 @@ int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
 EXPORT_SYMBOL(sysctl_ip_default_ttl);
 
 /* Generate a checksum for an outgoing IP datagram. */
-__inline__ void ip_send_check(struct iphdr *iph)
+void ip_send_check(struct iphdr *iph)
 {
 	iph->check = 0;
 	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
-- 
1.8.1.4
