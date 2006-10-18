From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] rt2x00: Remove xr_end references
Date: Wed, 18 Oct 2006 18:07:11 +0200
Message-ID: <200610181807.11677.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:52204 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161225AbWJRQIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 12:08:49 -0400
Received: by nf-out-0910.google.com with SMTP id c2so712238nfe
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 09:08:48 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes the xr_end references from rt2500usb and rt71usb.
The rt2x00 pci drivers were already fixed by David Kimdon.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index 5d119cd..a181829 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -2676,11 +2676,6 @@ static int rt2500usb_init_hw_modes(struc
 	rt2500usb_init_hw_channels(rt2x00dev, hw->modes[0].channels);
 	rt2500usb_init_hw_rates(rt2x00dev, hw->modes[0].rates);
 
-	/*
-	 * xr_end is only used on Atheros cards.
-	 */
-	hw->modes->xr_end = 0;
-
 	return ieee80211_update_hw(net_dev, hw);
 
 exit_free_channels:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index a3b0996..12407d3 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -3037,11 +3037,6 @@ static int rt73usb_init_hw_modes(struct 
 	rt73usb_init_hw_channels(rt2x00dev, hw->modes[0].channels);
 	rt73usb_init_hw_rates(rt2x00dev, hw->modes[0].rates);
 
-	/*
-	 * xr_end is only used on Atheros cards.
-	 */
-	hw->modes->xr_end = 0;
-
 	return ieee80211_update_hw(net_dev, hw);
 
 exit_free_channels:
