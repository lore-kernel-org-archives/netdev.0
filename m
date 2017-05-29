From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 09/17] net: qca_spi: Clarify MODULE_DESCRIPTION
Date: Mon, 29 May 2017 13:57:17 +0200
Message-ID: <1496059045-13572-10-git-send-email-stefan.wahren@i2se.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:57047 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdE2L7T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 07:59:19 -0400
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since this driver is specific to the QCA7000, we should make the module
description more precisely.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_spi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 50adc4f..ee90af3 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -999,7 +999,7 @@ static struct spi_driver qca_spi_driver = {
 };
 module_spi_driver(qca_spi_driver);
 
-MODULE_DESCRIPTION("Qualcomm Atheros SPI Driver");
+MODULE_DESCRIPTION("Qualcomm Atheros QCA7000 SPI Driver");
 MODULE_AUTHOR("Qualcomm Atheros Communications");
 MODULE_AUTHOR("Stefan Wahren <stefan.wahren@i2se.com>");
 MODULE_LICENSE("Dual BSD/GPL");
-- 
2.1.4
