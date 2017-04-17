From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 10/25] net: mvpp2: Improve another size determination in
 mvpp2_prs_default_init()
Date: Mon, 17 Apr 2017 17:20:10 +0200
Message-ID: <b9916870-d267-7b7f-c508-f53cc6df9cd6@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 09:12:34 +0200

Replace the specification of a data structure by a pointer dereference
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 8fb039b2073e..abf084b43af7 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3205,7 +3205,7 @@ static int mvpp2_prs_default_init(struct platform_device *pdev,
 		mvpp2_prs_hw_inv(priv, index);
 
 	priv->prs_shadow = devm_kcalloc(&pdev->dev, MVPP2_PRS_TCAM_SRAM_SIZE,
-					sizeof(struct mvpp2_prs_shadow),
+					sizeof(*priv->prs_shadow),
 					GFP_KERNEL);
 	if (!priv->prs_shadow)
 		return -ENOMEM;
-- 
2.12.2

