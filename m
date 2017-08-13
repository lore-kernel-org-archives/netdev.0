From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 1/4] can: constify platform_device_id
Date: Sun, 13 Aug 2017 16:41:45 +0530
Message-ID: <1502622705-11169-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502622705-11169-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org
To: wg@grandegger.com, mkl@pengutronix.de, madalin.bucur@nxp.com,
        davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
        grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502622705-11169-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

platform_device_id are not supposed to change at runtime. All functions
working with platform_device_id provided by <linux/platform_device.h>
work with const platform_device_id. So mark the non-const structs as
const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/can/c_can/c_can_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index e36d105..46a746e 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -220,7 +220,7 @@ static const struct c_can_driver_data am3352_dcan_drvdata = {
 	.raminit_bits = am3352_raminit_bits,
 };
 
-static struct platform_device_id c_can_id_table[] = {
+static const struct platform_device_id c_can_id_table[] = {
 	{
 		.name = KBUILD_MODNAME,
 		.driver_data = (kernel_ulong_t)&c_can_drvdata,
-- 
2.7.4
