From: Joe Perches <joe@perches.com>
Subject: [PATCH net-hext] wireless: scan: Remove comment to
 compare_ether_addr
Date: Sun, 01 Sep 2013 15:48:27 -0700
Message-ID: <1378075707.1953.29.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function is being removed, so remove the reference to it.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/wireless/scan.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index ad1e406..eeb7148 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -465,10 +465,6 @@ static int cmp_bss(struct cfg80211_bss *a,
 		}
 	}
 
-	/*
-	 * we can't use compare_ether_addr here since we need a < > operator.
-	 * The binary return value of compare_ether_addr isn't enough
-	 */
 	r = memcmp(a->bssid, b->bssid, sizeof(a->bssid));
 	if (r)
 		return r;
