From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 18/25] net: mvpp2: Rename a jump label in
 mvpp2_prs_double_vlan_add()
Date: Mon, 17 Apr 2017 17:28:10 +0200
Message-ID: <489b0f89-c362-e931-0b5a-baa0df84b275@users.sourceforge.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 13:03:49 +0200

Adjust jump labels according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index a5cd1036012a..0c190bd003b1 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -2139,7 +2139,7 @@ static int mvpp2_prs_double_vlan_add(struct mvpp2 *priv, unsigned short tpid1,
 		ai = mvpp2_prs_double_vlan_ai_free_get(priv);
 		if (ai < 0) {
 			ret = ai;
-			goto error;
+			goto free_pe;
 		}
 
 		/* Get first single/triple vlan tid */
@@ -2162,7 +2162,7 @@ static int mvpp2_prs_double_vlan_add(struct mvpp2 *priv, unsigned short tpid1,
 
 		if (tid >= tid_aux) {
 			ret = -ERANGE;
-			goto error;
+			goto free_pe;
 		}
 
 		memset(pe, 0, sizeof(*pe));
@@ -2189,8 +2189,7 @@ static int mvpp2_prs_double_vlan_add(struct mvpp2 *priv, unsigned short tpid1,
 	/* Update ports' mask */
 	mvpp2_prs_tcam_port_map_set(pe, port_map);
 	mvpp2_prs_hw_write(priv, pe);
-
-error:
+free_pe:
 	kfree(pe);
 	return ret;
 }
-- 
2.12.2
