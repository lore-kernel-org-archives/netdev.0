From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 08/17] net: qca_spi: Clarify MODULE_DESCRIPTION
Date: Wed, 10 May 2017 10:53:19 +0200
Message-ID: <1494406408-31760-9-git-send-email-stefan.wahren@i2se.com>
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

Since this driver is specific to the QCA7000, we should make the module
description more precisely.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_spi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index c727357..deec70f 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -997,7 +997,7 @@ static struct spi_driver qca_spi_driver = {
 };
 module_spi_driver(qca_spi_driver);
 
-MODULE_DESCRIPTION("Qualcomm Atheros SPI Driver");
+MODULE_DESCRIPTION("Qualcomm Atheros QCA7000 SPI Driver");
 MODULE_AUTHOR("Qualcomm Atheros Communications");
 MODULE_AUTHOR("Stefan Wahren <stefan.wahren@i2se.com>");
 MODULE_LICENSE("Dual BSD/GPL");
-- 
2.1.4
