From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 03/17] net: qca_7k: Use BIT macro
Date: Wed, 10 May 2017 10:53:14 +0200
Message-ID: <1494406408-31760-4-git-send-email-stefan.wahren@i2se.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the BIT macro for the CONFIG and INT register values.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_7k.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_7k.h b/drivers/net/ethernet/qualcomm/qca_7k.h
index 1cad851..4047f0a 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k.h
+++ b/drivers/net/ethernet/qualcomm/qca_7k.h
@@ -54,15 +54,15 @@
 #define SPI_REG_ACTION_CTRL     0x1B00
 
 /*   SPI_CONFIG register definition;             */
-#define QCASPI_SLAVE_RESET_BIT (1 << 6)
+#define QCASPI_SLAVE_RESET_BIT  BIT(6)
 
 /*   INTR_CAUSE/ENABLE register definition.      */
-#define SPI_INT_WRBUF_BELOW_WM (1 << 10)
-#define SPI_INT_CPU_ON         (1 << 6)
-#define SPI_INT_ADDR_ERR       (1 << 3)
-#define SPI_INT_WRBUF_ERR      (1 << 2)
-#define SPI_INT_RDBUF_ERR      (1 << 1)
-#define SPI_INT_PKT_AVLBL      (1 << 0)
+#define SPI_INT_WRBUF_BELOW_WM  BIT(10)
+#define SPI_INT_CPU_ON          BIT(6)
+#define SPI_INT_ADDR_ERR        BIT(3)
+#define SPI_INT_WRBUF_ERR       BIT(2)
+#define SPI_INT_RDBUF_ERR       BIT(1)
+#define SPI_INT_PKT_AVLBL       BIT(0)
 
 void qcaspi_spi_error(struct qcaspi *qca);
 int qcaspi_read_register(struct qcaspi *qca, u16 reg, u16 *result);
-- 
2.1.4
