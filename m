From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 10/11] net: ipv4: hlen could be set as size_t
Date: Fri, 23 Oct 2015 14:10:35 +0200
Message-ID: <1445602236-24130-11-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, jmorris@namei.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hlen member of raw_frag_vec is used in operation/function that wait
for unsigned value. So it need to be set as size_t.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/ipv4/raw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 561cd4b..a00aaed 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -86,7 +86,7 @@ struct raw_frag_vec {
 		struct icmphdr icmph;
 		char c[1];
 	} hdr;
-	int hlen;
+	size_t hlen;
 };
 
 static struct raw_hashinfo raw_v4_hashinfo = {
-- 
2.4.10
