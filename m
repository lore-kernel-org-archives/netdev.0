From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/4] ATM-ZeitNet: Fix indentation for one DPRINTK() call in
 start_rx()
Date: Sat, 10 Sep 2016 11:03:54 +0200
Message-ID: <f5d3315e-61be-2697-0847-784cd6f1ab05@users.sourceforge.net>
References: <0b5381e1-d725-0706-1cc0-188df6c201f2@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Paolo Bonzini <pbonzini@redhat.com>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0b5381e1-d725-0706-1cc0-188df6c201f2@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 10 Sep 2016 10:38:04 +0200

Adjust the indentation for a call of the macro "DPRINTK" in this function.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/zatm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 2cc9e2a..d3dc954 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -600,7 +600,7 @@ static int start_rx(struct atm_dev *dev)
 	struct zatm_dev *zatm_dev;
 	int i;
 
-DPRINTK("start_rx\n");
+	DPRINTK("start_rx\n");
 	zatm_dev = ZATM_DEV(dev);
 	zatm_dev->rx_map = kcalloc(zatm_dev->chans,
 				   sizeof(*zatm_dev->rx_map),
-- 
2.10.0
