From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net-next v3 2/4] dt-bindings: net: add EEE capability constants
Date: Mon, 28 Nov 2016 10:46:47 +0100
Message-ID: <1480326409-25419-3-git-send-email-jbrunet@baylibre.com>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
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
