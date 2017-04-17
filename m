From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 19/25] net: mvpp2: Rename a jump label in mvpp2_prs_vlan_add()
Date: Mon, 17 Apr 2017 17:29:04 +0200
Message-ID: <949a3bd7-7b65-8a9e-c535-6fafeb06f1a2@users.sourceforge.net>
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
Date: Mon, 17 Apr 2017 13:50:35 +0200

Adjust jump labels according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 0c190bd003b1..3bdd3f1fe34e 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -2021,7 +2021,7 @@ static int mvpp2_prs_vlan_add(struct mvpp2 *priv, unsigned short tpid, int ai,
 
 		if (tid <= tid_aux) {
 			ret = -EINVAL;
-			goto error;
+			goto free_pe;
 		}
 
 		memset(pe, 0, sizeof(*pe));
@@ -2053,8 +2053,7 @@ static int mvpp2_prs_vlan_add(struct mvpp2 *priv, unsigned short tpid, int ai,
 	mvpp2_prs_tcam_port_map_set(pe, port_map);
 
 	mvpp2_prs_hw_write(priv, pe);
-
-error:
+free_pe:
 	kfree(pe);
 
 	return ret;
-- 
2.12.2
