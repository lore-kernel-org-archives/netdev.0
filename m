From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/2] rndis_wlan: allow devdbg arguments to be type-checked without DEBUG
Date: Tue, 20 Jan 2009 13:07:17 +0000
Message-ID: <1232456838-10025-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	David Brownell <david-b@pacbell.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:48218 "EHLO
	kensington.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756128AbZATNbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 08:31:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes an #ifdef DEBUG directive so devdbg statements can be
type-checked at compile time.  Type checking itself is introduced by
another patch in this series.

This introduces an unused variable warning which disappears with the
type-checking patch.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/wireless/rndis_wlan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 607ce9f..ed93ac4 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1649,9 +1649,7 @@ static char *rndis_translate_scan(struct net_device *dev,
 				  char *end_buf,
 				  struct ndis_80211_bssid_ex *bssid)
 {
-#ifdef DEBUG
 	struct usbnet *usbdev = netdev_priv(dev);
-#endif
 	u8 *ie;
 	char *current_val;
 	int bssid_len, ie_len, i;
-- 
1.6.0.6

