From: "Aviad Krawczyk (A)" <aviad.krawczyk@huawei.com>
Subject: RE: [PATCH][net-next] net: hinic: make functions set_ctrl0 and
 set_ctrl1 static
Date: Wed, 23 Aug 2017 10:08:58 +0000
Message-ID: <1C47E215DC9A8B4DBCB6C24F1DE66D8E0294323E@FRAEML521-MBX.china.huawei.com>
References: <20170823095940.27225-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:33678 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753651AbdHWKJD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 06:09:03 -0400
In-Reply-To: <20170823095940.27225-1-colin.king@canonical.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks

-----Original Message-----
From: Colin King [mailto:colin.king@canonical.com] 
Sent: Wednesday, August 23, 2017 1:00 PM
To: Aviad Krawczyk (A); netdev@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: [PATCH][net-next] net: hinic: make functions set_ctrl0 and set_ctrl1 static

From: Colin Ian King <colin.king@canonical.com>

The functions set_ctrl0 and set_ctrl1 are local to the source and do not need to be in global scope, so make them static.

Cleans up sparse warnings:
symbol 'set_ctrl0' was not declared. Should it be static?
symbol 'set_ctrl1' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
index cd09e6ef3aea..7cb8b9b94726 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
@@ -423,7 +423,7 @@ static irqreturn_t ceq_interrupt(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-void set_ctrl0(struct hinic_eq *eq)
+static void set_ctrl0(struct hinic_eq *eq)
 {
 	struct msix_entry *msix_entry = &eq->msix_entry;
 	enum hinic_eq_type type = eq->type;
@@ -474,7 +474,7 @@ void set_ctrl0(struct hinic_eq *eq)
 	}
 }
 
-void set_ctrl1(struct hinic_eq *eq)
+static void set_ctrl1(struct hinic_eq *eq)
 {
 	enum hinic_eq_type type = eq->type;
 	u32 page_size_val, elem_size;
