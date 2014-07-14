From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 08/16] mac80211: remove unnecessary break after return
Date: Mon, 14 Jul 2014 18:30:58 +0200
Message-ID: <1405355467-7350-9-git-send-email-fabf@skynet.be>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/mac80211/mesh_hwmp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 94758b9..214e63b 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -157,7 +157,6 @@ static int mesh_path_sel_frame_tx(enum mpath_frame_type action, u8 flags,
 	default:
 		kfree_skb(skb);
 		return -ENOTSUPP;
-		break;
 	}
 	*pos++ = ie_len;
 	*pos++ = flags;
-- 
1.8.4.5
