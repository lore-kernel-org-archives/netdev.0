From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: dsa: bcm_sf2: Fix non static symbol warning
Date: Thu, 15 Sep 2016 02:24:13 +0000
Message-ID: <1473906253-1424-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36497 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754740AbcIOCYY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 22:24:24 -0400
Received: by mail-pf0-f194.google.com with SMTP id n24so1542221pfb.3
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 19:24:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/dsa/bcm_sf2.c:963:19: warning:
 symbol 'bcm_sf2_io_ops' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/dsa/bcm_sf2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 51f1fc0..f8bb5a5 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -960,7 +960,7 @@ static int bcm_sf2_core_write64(struct b53_device *dev, u8 page, u8 reg,
 	return 0;
 }
 
-struct b53_io_ops bcm_sf2_io_ops = {
+static struct b53_io_ops bcm_sf2_io_ops = {
 	.read8	= bcm_sf2_core_read8,
 	.read16	= bcm_sf2_core_read16,
 	.read32	= bcm_sf2_core_read32,
