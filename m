From: Pavel Machek <pavel@ucw.cz>
Subject: ipw2100 wireless driver
Date: Wed, 14 Jul 2004 13:41:35 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040714114135.GA25175@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265974AbUGNLlv@vger.kernel.org>
To: netdev@oss.sgi.com, kernel list <linux-kernel@vger.kernel.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi!

What is the status of ipw2100? Is there chance that it would be pushed
into mainline?

I have few problems with that:

* it will not compile with gcc-2.95. Attached patch fixes one problem
but more remain.

--- ipw2100-ofic/ieee80211.h	2004-07-09 06:32:17.000000000 +0200
+++ ipw2100-0.49/ieee80211.h	2004-07-14 13:18:50.000000000 +0200
@@ -440,7 +440,7 @@
 	u16 reserved;
 	u16 frag_size;
 	u16 payload_size;
-	struct sk_buff *fragments[];
+	struct sk_buff *fragments[1];
 };
 
 extern struct ieee80211_txb *ieee80211_skb_to_txb(struct ieee80211_device *ieee, 

* it requires CONFIG_CRYPTO, but fails to force it in Kconfig.

									Pavel
-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
