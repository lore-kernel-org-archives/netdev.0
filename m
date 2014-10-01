From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] cipso: add __init to cipso_v4_cache_init
Date: Wed,  1 Oct 2014 19:30:03 +0200
Message-ID: <1412184603-17294-1-git-send-email-fabf@skynet.be>
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

cipso_v4_cache_init is only called by __init cipso_v4_init

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/cipso_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 05b708b..4715f25 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -246,7 +246,7 @@ static u32 cipso_v4_map_cache_hash(const unsigned char *key, u32 key_len)
  * success, negative values on error.
  *
  */
-static int cipso_v4_cache_init(void)
+static int __init cipso_v4_cache_init(void)
 {
 	u32 iter;
 
-- 
1.9.3
