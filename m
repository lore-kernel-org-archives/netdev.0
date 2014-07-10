From: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Subject: [PATCH v7 17/33] net: airo - set name assign type
Date: Thu, 10 Jul 2014 10:17:22 +0200
Message-ID: <1404980258-30853-18-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>, Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg-B22kvLQNl6c@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

alloc_netdev is first called without a name, before the name and name assign
type is open-coded later.

Signed-off-by: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Cc: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/wireless/airo.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 8a93e78..2156b03 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2859,6 +2859,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	}
 
 	strcpy(dev->name, "eth%d");
+	dev->name_assign_type = NET_NAME_ENUM;
 	rc = register_netdev(dev);
 	if (rc) {
 		airo_print_err(dev->name, "Couldn't register_netdev");
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
