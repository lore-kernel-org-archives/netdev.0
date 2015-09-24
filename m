From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 18/19] mac80211: make ieee80211_new_mesh_header return unsigned
Date: Thu, 24 Sep 2015 16:00:26 +0200
Message-ID: <1443103227-25612-19-git-send-email-a.hajda@samsung.com>
References: <1443103227-25612-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1443103227-25612-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function returns always non-negative values.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2046107

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
Hi,

To avoid problems with too many mail recipients I have sent whole
patchset only to LKML. Anyway patches have no dependencies.

Regards
Andrzej
---
 net/mac80211/mesh.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index e06a5ca..09de65a 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -540,7 +540,7 @@ int ieee80211_fill_mesh_addresses(struct ieee80211_hdr *hdr, __le16 *fc,
  *
  * Return the header length.
  */
-int ieee80211_new_mesh_header(struct ieee80211_sub_if_data *sdata,
+unsigned int ieee80211_new_mesh_header(struct ieee80211_sub_if_data *sdata,
 			      struct ieee80211s_hdr *meshhdr,
 			      const char *addr4or5, const char *addr6)
 {
-- 
1.9.1
