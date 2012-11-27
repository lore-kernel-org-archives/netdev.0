From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 2/2] ewrk3: remove outdated comment
Date: Tue, 27 Nov 2012 10:48:34 +0100
Message-ID: <1354009714.1420.52.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	richard -rw- weinberger <richard.weinberger@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove an outdated comment, that should have been removed in the
patch named "MODULE_PARM conversions" from early 2005.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/net/ethernet/dec/ewrk3.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
index 2ee1c47..9f992b9 100644
--- a/drivers/net/ethernet/dec/ewrk3.c
+++ b/drivers/net/ethernet/dec/ewrk3.c
@@ -1910,7 +1910,6 @@ static struct net_device *ewrk3_devs[MAX_NUM_EWRK3S];
 static int ndevs;
 static int io[MAX_NUM_EWRK3S+1] = { 0x300, 0, };
 
-/* '21' below should really be 'MAX_NUM_EWRK3S' */
 module_param_array(io, int, NULL, 0);
 module_param_array(irq, byte, NULL, 0);
 MODULE_PARM_DESC(io, "EtherWORKS 3 I/O base address(es)");
-- 
1.7.7.6
