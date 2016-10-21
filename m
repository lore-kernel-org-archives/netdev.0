From: Xo Wang <xow@google.com>
Subject: [PATCH 1/2] net: phy: broadcom: Update Auxiliary Control Register macros
Date: Fri, 21 Oct 2016 10:20:12 -0700
Message-ID: <1477070413-92621-2-git-send-email-xow@google.com>
References: <1477070413-92621-1-git-send-email-xow@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, openbmc@lists.ozlabs.org,
        joel@jms.id.au, Xo Wang <xow@google.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35485 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932799AbcJURU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 13:20:26 -0400
Received: by mail-pf0-f175.google.com with SMTP id s8so59982109pfj.2
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 10:20:26 -0700 (PDT)
In-Reply-To: <1477070413-92621-1-git-send-email-xow@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the RXD-to-RXC skew (delay) time bit in the Miscellaneous Control
shadow register and a mask for the shadow selector field.

Remove a re-definition of MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL.

Signed-off-by: Xo Wang <xow@google.com>
---
 include/linux/brcmphy.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index e3354b7..22c4421 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -105,11 +105,12 @@
 #define MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA	0x0800
 
 #define MII_BCM54XX_AUXCTL_MISC_WREN	0x8000
+#define MII_BCM54XX_AUXCTL_MISC_RXD_RXC_SKEW	0x0100
 #define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
 #define MII_BCM54XX_AUXCTL_MISC_RDSEL_MISC	0x7000
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
 
-#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
+#define MII_BCM54XX_AUXCTL_SHDWSEL_MASK	0x0007
 
 /*
  * Broadcom LED source encodings.  These are used in BCM5461, BCM5481,
-- 
2.8.0.rc3.226.g39d4020
