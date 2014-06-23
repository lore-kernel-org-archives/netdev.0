From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2] net/dsa/dsa.c: remove unnecessary null test before kfree
Date: Mon, 23 Jun 2014 19:32:47 +0200
Message-ID: <1403544767-12438-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix checkpatch warning:
WARNING: kfree(NULL) is safe this check is probably not required

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: netdev@vger.kernel.org
Cc: Joe Perches <joe@perches.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: Use more appropriate subject (suggested by Joe Perches).

 net/dsa/dsa.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 5db37ce..0a49632 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -351,8 +351,7 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 	for (i = 0; i < pd->nr_chips; i++) {
 		port_index = 0;
 		while (port_index < DSA_MAX_PORTS) {
-			if (pd->chip[i].port_names[port_index])
-				kfree(pd->chip[i].port_names[port_index]);
+			kfree(pd->chip[i].port_names[port_index]);
 			port_index++;
 		}
 		kfree(pd->chip[i].rtable);
-- 
1.8.4.5
