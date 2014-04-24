From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 10/14] at86rf230: remove
	unnecessary assign
Date: Thu, 24 Apr 2014 19:09:14 +0200
Message-ID: <1398359358-11085-11-git-send-email-alex.aring@gmail.com>
References: <1398359358-11085-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1398359358-11085-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index b324bb3..960444b 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -693,10 +693,7 @@ at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
 	if (rc < 0)
 		goto err_rx;
 
-	rc = at86rf230_start(dev);
-
-	return rc;
-
+	return at86rf230_start(dev);
 err_rx:
 	at86rf230_start(dev);
 err:
-- 
1.9.2


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
