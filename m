From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 06/17] net: qca_spi: remove QCASPI_MTU
Date: Wed, 10 May 2017 10:53:17 +0200
Message-ID: <1494406408-31760-7-git-send-email-stefan.wahren@i2se.com>
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

There is no need for an additional MTU define.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_spi.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index a0dbb92..a239ac4 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -69,7 +69,6 @@ static int qcaspi_pluggable = QCASPI_PLUGGABLE_MIN;
 module_param(qcaspi_pluggable, int, 0);
 MODULE_PARM_DESC(qcaspi_pluggable, "Pluggable SPI connection (yes/no).");
 
-#define QCASPI_MTU QCAFRM_MAX_MTU
 #define QCASPI_TX_TIMEOUT (1 * HZ)
 #define QCASPI_QCA7K_REBOOT_TIME_MS 1000
 
@@ -745,7 +744,7 @@ qcaspi_netdev_init(struct net_device *dev)
 {
 	struct qcaspi *qca = netdev_priv(dev);
 
-	dev->mtu = QCASPI_MTU;
+	dev->mtu = QCAFRM_MAX_MTU;
 	dev->type = ARPHRD_ETHER;
 	qca->clkspeed = qcaspi_clkspeed;
 	qca->burst_len = qcaspi_burst_len;
-- 
2.1.4
