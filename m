From: Sergio Prado <sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org>
Subject: [PATCH net-next] net: macb: make magic-packet property generic
Date: Mon, 15 Feb 2016 22:13:58 -0200
Message-ID: <1455581638-27771-1-git-send-email-sergio.prado@e-labworks.com>
Cc: Sergio Prado <sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
	michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Sergio Prado <sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org>
---
As requested by Rob Herring on patch
https://patchwork.ozlabs.org/patch/580862/
---
 Documentation/devicetree/bindings/net/macb.txt | 2 +-
 drivers/net/ethernet/cadence/macb.c            | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index c6b1cb5ffa87..b5a42df4c928 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -25,7 +25,7 @@ Required properties:
 
 Optional properties for PHY child node:
 - reset-gpios : Should specify the gpio for phy reset
-- cdns,magic-packet : If present, indicates that the hardware supports waking
+- magic-packet : If present, indicates that the hardware supports waking
   up via magic packet.
 
 Examples:
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 69af049e55a8..7ccf2298a5fa 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2929,7 +2929,7 @@ static int macb_probe(struct platform_device *pdev)
 		bp->jumbo_max_len = macb_config->jumbo_max_len;
 
 	bp->wol = 0;
-	if (of_get_property(np, "cdns,magic-packet", NULL))
+	if (of_get_property(np, "magic-packet", NULL))
 		bp->wol |= MACB_WOL_HAS_MAGIC_PACKET;
 	device_init_wakeup(&pdev->dev, bp->wol & MACB_WOL_HAS_MAGIC_PACKET);
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
