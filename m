From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: [PATCH] net: wireless: ipw2x00: ipw2200.c:  Remove unused function
Date: Sat, 20 Dec 2014 13:29:59 +0100
Message-ID: <1419078599-31118-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove the function ipw_alive() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
---
 drivers/net/wireless/ipw2x00/ipw2200.c |   14 --------------
 1 file changed, 14 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index edc3443..2f830ca 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -3021,20 +3021,6 @@ static void ipw_remove_current_network(struct ipw_priv *priv)
 	spin_unlock_irqrestore(&priv->ieee->lock, flags);
 }
 
-/**
- * Check that card is still alive.
- * Reads debug register from domain0.
- * If card is present, pre-defined value should
- * be found there.
- *
- * @param priv
- * @return 1 if card is present, 0 otherwise
- */
-static inline int ipw_alive(struct ipw_priv *priv)
-{
-	return ipw_read32(priv, 0x90) == 0xd55555d5;
-}
