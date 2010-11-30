From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [PATCH 47/62] vmxnet3: Use static const
Date: Tue, 30 Nov 2010 10:15:58 -0800
Message-ID: <89E2752CFA8EC044846EB8499819134102BD7E186D@EXCH-MBX-4.vmware.com>
References: <cover.1290305773.git.joe@perches.com>,<76d2bd45fbde30f47992b99cf5014dbab4079882.1290305776.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <76d2bd45fbde30f47992b99cf5014dbab4079882.1290305776.git.joe@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Joe.

Acked-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
Acked-by: Scott J. Goldman <scottjg@vmware.com>



________________________________________
From: Joe Perches [joe@perches.com]
Sent: Saturday, November 20, 2010 6:38 PM
To: Shreyas Bhatewara; VMware, Inc.
Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: [PATCH 47/62] vmxnet3: Use static const

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text    data     bss     dec     hex filename
  38916     437    9160   48513    bd81 drivers/net/vmxnet3/vmxnet3_drv.o.new
  38916     437    9160   48513    bd81 drivers/net/vmxnet3/vmxnet3_drv.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 21314e0..31dc45a 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1082,7 +1082,9 @@ static int
 vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
                       struct vmxnet3_adapter *adapter, int quota)
 {
-       static u32 rxprod_reg[2] = {VMXNET3_REG_RXPROD, VMXNET3_REG_RXPROD2};
+       static const u32 rxprod_reg[2] = {
+               VMXNET3_REG_RXPROD, VMXNET3_REG_RXPROD2
+       };
        u32 num_rxd = 0;
        struct Vmxnet3_RxCompDesc *rcd;
        struct vmxnet3_rx_ctx *ctx = &rq->rx_ctx;
