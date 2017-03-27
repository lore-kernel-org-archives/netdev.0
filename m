From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC net-next 1/3] net: mdio: add definition for MDIO_STAT1_CLOCK_STOP_CAPABLE
Date: Mon, 27 Mar 2017 11:47:19 -0700
Message-ID: <20170327184721.30275-2-f.fainelli@gmail.com>
References: <20170327184721.30275-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33545 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752135AbdC0Sr4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:47:56 -0400
Received: by mail-qk0-f196.google.com with SMTP id p22so9143250qka.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:47:31 -0700 (PDT)
In-Reply-To: <20170327184721.30275-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the definition for the Clause 45 IEEE PCS Status 1 Register (3.1)
reporting whether a PHY supports stopping its clock or not during LPI
(EEE).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/uapi/linux/mdio.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/mdio.h b/include/uapi/linux/mdio.h
index c94a510a577e..4f17427db4cd 100644
--- a/include/uapi/linux/mdio.h
+++ b/include/uapi/linux/mdio.h
@@ -96,6 +96,7 @@
 #define MDIO_STAT1_LPOWERABLE		0x0002	/* Low-power ability */
 #define MDIO_STAT1_LSTATUS		BMSR_LSTATUS
 #define MDIO_STAT1_FAULT		0x0080	/* Fault */
+#define MDIO_STAT1_CLOCK_STOP_CAPABLE	0x0040	/* Clock stop capable */
 #define MDIO_AN_STAT1_LPABLE		0x0001	/* Link partner AN ability */
 #define MDIO_AN_STAT1_ABLE		BMSR_ANEGCAPABLE
 #define MDIO_AN_STAT1_RFAULT		BMSR_RFAULT
-- 
2.9.3
