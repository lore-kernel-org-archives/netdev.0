From: akpm@linux-foundation.org
Subject: [patch 01/19] git-netdev-all: ipw2200 fix
Date: Tue, 06 Mar 2007 02:41:41 -0800
Message-ID: <200703061041.l26AffiW019732@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34617 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752939AbXCFKlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:41:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/wireless/ipw2200.c: In function 'show_channels':
drivers/net/wireless/ipw2200.c:1855: warning: implicit declaration of function 'ipw_get_geo'
drivers/net/wireless/ipw2200.c:1855: warning: initialization makes pointer from integer without a cast


Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wireless/ipw2200.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wireless/ipw2200.c~git-netdev-all-ipw2200-fix drivers/net/wireless/ipw2200.c
--- a/drivers/net/wireless/ipw2200.c~git-netdev-all-ipw2200-fix
+++ a/drivers/net/wireless/ipw2200.c
@@ -1852,7 +1852,7 @@ static ssize_t show_channels(struct devi
 			     char *buf)
 {
 	struct ipw_priv *priv = dev_get_drvdata(d);
-	const struct ieee80211_geo *geo = ipw_get_geo(priv->ieee);
+	const struct ieee80211_geo *geo = ieee80211_get_geo(priv->ieee);
 	int len = 0, i;
 
 	len = sprintf(&buf[len],
_
