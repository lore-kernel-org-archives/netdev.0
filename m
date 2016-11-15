From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 15/15] net: usb: lan78xx: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:44 -0800
Message-ID: <20161115180644.3941-16-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:USB NETWORKING DRIVERS),
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/lan78xx.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index bcd9010c1f27..cf2857fa938f 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1447,11 +1447,6 @@ static u32 lan78xx_get_link(struct net_device *net)
 	return net->phydev->link;
 }
 
-static int lan78xx_nway_reset(struct net_device *net)
-{
-	return phy_start_aneg(net->phydev);
-}
