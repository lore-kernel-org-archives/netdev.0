From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] cipso: remove NULL assignment on static
Date: Tue,  4 Nov 2014 20:19:19 +0100
Message-ID: <1415128759-11264-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also add blank line after structure declarations

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/cipso_ipv4.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 4715f25..dd3746a 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -72,6 +72,7 @@ struct cipso_v4_map_cache_bkt {
 	u32 size;
 	struct list_head list;
 };
+
 struct cipso_v4_map_cache_entry {
 	u32 hash;
 	unsigned char *key;
@@ -82,7 +83,8 @@ struct cipso_v4_map_cache_entry {
 	u32 activity;
 	struct list_head list;
 };
-static struct cipso_v4_map_cache_bkt *cipso_v4_cache = NULL;
+
+static struct cipso_v4_map_cache_bkt *cipso_v4_cache;
 
 /* Restricted bitmap (tag #1) flags */
 int cipso_v4_rbm_optfmt = 0;
-- 
1.9.3
