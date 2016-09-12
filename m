From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] atm: iphase: fix newline escape and minor tweak to source formatting Content-Type: text/plain; charset="utf-8" Content-Transfer-Encoding: 8bit
Date: Mon, 12 Sep 2016 13:01:50 +0100
Message-ID: <20160912120150.31390-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The newline escape is incorrect and needs fixing. Also adjust source
formatting / indentation and add { } to trailing else.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/atm/iphase.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 9d8807e..ddb244e 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -1885,9 +1885,9 @@ static int open_tx(struct atm_vcc *vcc)
                 if ((ret = ia_cbr_setup (iadev, vcc)) < 0) {     
                     return ret;
                 }
-       } 
-	else  
-           printk("iadev:  Non UBR, ABR and CBR traffic not supportedn"); 
+	} else {
+		printk("iadev:  Non UBR, ABR and CBR traffic not supported\n");
+	}
         
         iadev->testTable[vcc->vci]->vc_status |= VC_ACTIVE;
 	IF_EVENT(printk("ia open_tx returning \n");)  
-- 
2.9.3
