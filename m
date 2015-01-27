From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/4] net: phy: document has_fixups field
Date: Mon, 26 Jan 2015 22:05:38 -0800
Message-ID: <1422338740-18418-3-git-send-email-f.fainelli@gmail.com>
References: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, s.hauer@pengutronix.de, b38611@freescale.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:42042 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757460AbbA0GGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 01:06:04 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so16399666pab.3
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 22:06:03 -0800 (PST)
In-Reply-To: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

has_fixups was introduced to help keeping track of fixups/quirks running
on a PHY device, but we did not update the comment above struct
phy_device accordingly.

Fixes: b0ae009f3dc14 (net: phy: add "has_fixups" boolean property")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
No changes in v2

 include/linux/phy.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 9c189a1fa3a2..1b3690b597d5 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -327,6 +327,7 @@ struct phy_c45_device_ids {
  * c45_ids: 802.3-c45 Device Identifers if is_c45.
  * is_c45:  Set to true if this phy uses clause 45 addressing.
  * is_internal: Set to true if this phy is internal to a MAC.
+ * has_fixups: Set to true if this phy has fixups/quirks.
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
  * addr: Bus address of PHY
-- 
2.1.0
