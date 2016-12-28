From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: wan: slic_ds26522: fix spelling mistake: "configurated" -> "configured"
Date: Wed, 28 Dec 2016 16:44:23 +0000
Message-ID: <20161228164423.19070-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Zhao Qiang <qiang.zhao@nxp.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in pr_info message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wan/slic_ds26522.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/slic_ds26522.c b/drivers/net/wan/slic_ds26522.c
index b776a0a..9d9b4e0 100644
--- a/drivers/net/wan/slic_ds26522.c
+++ b/drivers/net/wan/slic_ds26522.c
@@ -218,7 +218,7 @@ static int slic_ds26522_probe(struct spi_device *spi)
 
 	ret = slic_ds26522_init_configure(spi);
 	if (ret == 0)
-		pr_info("DS26522 cs%d configurated\n", spi->chip_select);
+		pr_info("DS26522 cs%d configured\n", spi->chip_select);
 
 	return ret;
 }
-- 
2.10.2
