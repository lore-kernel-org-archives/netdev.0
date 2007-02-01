From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] ieee80211: Fix sparse warning
Date: Wed, 31 Jan 2007 18:50:19 -0600
Message-ID: <45c1394b.An8WeE68tSLsbJYy%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Sparse issues the warning "warning: symbol 'crypt' shadows an earlier one"
in net/ieee80211/ieee80211_tx.c.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

Index: wireless-2.6/net/ieee80211/ieee80211_tx.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/ieee80211_tx.c
+++ wireless-2.6/net/ieee80211/ieee80211_tx.c
@@ -502,8 +502,6 @@ int ieee80211_xmit(struct sk_buff *skb, 
 		if (host_encrypt)
 			ieee80211_encrypt_fragment(ieee, skb_frag, hdr_len);
 		else if (host_build_iv) {
-			struct ieee80211_crypt_data *crypt;
-
 			crypt = ieee->crypt[ieee->tx_keyidx];
 			atomic_inc(&crypt->refcnt);
 			if (crypt->ops->build_iv)
