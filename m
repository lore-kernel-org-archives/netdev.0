From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net-next v4 2/4] dt-bindings: net: add EEE capability constants
Date: Mon, 28 Nov 2016 16:50:26 +0100
Message-ID: <1480348229-25672-3-git-send-email-jbrunet@baylibre.com>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Yegor Yefremov <yegorslists@googlemail.com>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34787 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754803AbcK1Pus (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 10:50:48 -0500
Received: by mail-wm0-f49.google.com with SMTP id u144so41677775wmu.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 07:50:47 -0800 (PST)
In-Reply-To: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
Tested-by: Yegor Yefremov <yegorslists@googlemail.com>
Tested-by: Andreas Färber <afaerber@suse.de>
Tested-by: Neil Armstrong <narmstrong@baylibre.com>
---
 include/dt-bindings/net/mdio.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)
 create mode 100644 include/dt-bindings/net/mdio.h

diff --git a/include/dt-bindings/net/mdio.h b/include/dt-bindings/net/mdio.h
new file mode 100644
index 000000000000..99c6d903d439
--- /dev/null
+++ b/include/dt-bindings/net/mdio.h
@@ -0,0 +1,19 @@
+/*
+ * This header provides generic constants for ethernet MDIO bindings
+ */
+
+#ifndef _DT_BINDINGS_NET_MDIO_H
+#define _DT_BINDINGS_NET_MDIO_H
+
+/*
+ * EEE capability Advertisement
+ */
+
+#define MDIO_EEE_100TX		0x0002	/* 100TX EEE cap */
+#define MDIO_EEE_1000T		0x0004	/* 1000T EEE cap */
+#define MDIO_EEE_10GT		0x0008	/* 10GT EEE cap */
+#define MDIO_EEE_1000KX		0x0010	/* 1000KX EEE cap */
+#define MDIO_EEE_10GKX4		0x0020	/* 10G KX4 EEE cap */
+#define MDIO_EEE_10GKR		0x0040	/* 10G KR EEE cap */
+
+#endif
-- 
2.7.4
