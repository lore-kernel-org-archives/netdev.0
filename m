From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 04/17] net: qca_spi: Use SET_NETDEV_DEV()
Date: Mon, 29 May 2017 13:57:12 +0200
Message-ID: <1496059045-13572-5-git-send-email-stefan.wahren@i2se.com>
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

Use SET_NETDEV_DEV() in qca_spi to create the "/sys/class/net/<if>/device"
symlink.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_spi.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 24ca7df..0c3fdee 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -894,6 +894,7 @@ qca_spi_probe(struct spi_device *spi)
 		return -ENOMEM;
 
 	qcaspi_netdev_setup(qcaspi_devs);
+	SET_NETDEV_DEV(qcaspi_devs, &spi->dev);
 
 	qca = netdev_priv(qcaspi_devs);
 	if (!qca) {
-- 
2.1.4
