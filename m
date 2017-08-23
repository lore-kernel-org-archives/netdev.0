From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: hinic: make functions set_ctrl0 and set_ctrl1 static
Date: Wed, 23 Aug 2017 10:59:40 +0100
Message-ID: <20170823095940.27225-1-colin.king@canonical.com>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The functions set_ctrl0 and set_ctrl1 are local to the source and do
not need to be in global scope, so make them static.

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
-- 
2.14.1
