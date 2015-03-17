From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 14/16 linux-next] ehea: constify of_device_id array
Date: Tue, 17 Mar 2015 19:40:26 +0100
Message-ID: <1426617628-937-5-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
 <1426617628-937-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426617628-937-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index c05e507..291c870 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -103,7 +103,7 @@ static int ehea_probe_adapter(struct platform_device *dev);
 
 static int ehea_remove(struct platform_device *dev);
 
-static struct of_device_id ehea_module_device_table[] = {
+static const struct of_device_id ehea_module_device_table[] = {
 	{
 		.name = "lhea",
 		.compatible = "IBM,lhea",
@@ -116,7 +116,7 @@ static struct of_device_id ehea_module_device_table[] = {
 };
 MODULE_DEVICE_TABLE(of, ehea_module_device_table);
 
-static struct of_device_id ehea_device_table[] = {
+static const struct of_device_id ehea_device_table[] = {
 	{
 		.name = "lhea",
 		.compatible = "IBM,lhea",
-- 
2.1.0
