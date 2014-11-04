From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH] drivers: net: ethernet: xilinx: xilinx_emaclite: revert the
 original commit "1db3ddff1602edf2390b7667dcbaa0f71512e3ea"
Date: Tue, 04 Nov 2014 22:43:17 +0800
Message-ID: <5458E605.6070801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	davem@davemloft.net, sthokal@xilinx.com, manuel.schoelling@gmx.de,
	f.fainelli@gmail.com, paul.gortmaker@windriver.com,
	ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Microblaze is a fpga soft core, it can be customized easily, which may
cause many various hardware version strings.

So the original fix patch based on hard-coded compatible version strings
is not a good idea (although it is correct for current issue). For it,
there will be a new solving way soon (which based on the device tree).

The original issue is related with qemu, so can only change the hardware
version string in qemu for it, then keep the original driver no touch (
qemu is for virtualization which has much easier life than real world).


Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 298fad3..28dbbdc 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1236,7 +1236,6 @@ static struct of_device_id xemaclite_of_match[] = {
 	{ .compatible = "xlnx,opb-ethernetlite-1.01.b", },
 	{ .compatible = "xlnx,xps-ethernetlite-1.00.a", },
 	{ .compatible = "xlnx,xps-ethernetlite-2.00.a", },
-	{ .compatible = "xlnx,xps-ethernetlite-2.00.b", },
 	{ .compatible = "xlnx,xps-ethernetlite-2.01.a", },
 	{ .compatible = "xlnx,xps-ethernetlite-3.00.a", },
 	{ /* end of list */ },
-- davem@davemloft.net
1.9.3
