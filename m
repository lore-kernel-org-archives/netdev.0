From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 07/17] net: qca_spi: remove QCASPI_MTU
Date: Mon, 29 May 2017 13:57:15 +0200
Message-ID: <1496059045-13572-8-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need for an additional MTU define.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_spi.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index f155548..7464628 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -69,7 +69,6 @@ static int qcaspi_pluggable = QCASPI_PLUGGABLE_MIN;
 module_param(qcaspi_pluggable, int, 0);
 MODULE_PARM_DESC(qcaspi_pluggable, "Pluggable SPI connection (yes/no).");
 
-#define QCASPI_MTU QCAFRM_MAX_MTU
 #define QCASPI_TX_TIMEOUT (1 * HZ)
 #define QCASPI_QCA7K_REBOOT_TIME_MS 1000
 
@@ -746,7 +745,7 @@ qcaspi_netdev_init(struct net_device *dev)
 {
 	struct qcaspi *qca = netdev_priv(dev);
 
-	dev->mtu = QCASPI_MTU;
+	dev->mtu = QCAFRM_MAX_MTU;
 	dev->type = ARPHRD_ETHER;
 	qca->clkspeed = qcaspi_clkspeed;
 	qca->burst_len = qcaspi_burst_len;
-- 
2.1.4
