From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 12/25] net: mvpp2: Improve a size determination in two
 functions
Date: Mon, 17 Apr 2017 17:22:15 +0200
Message-ID: <954d79a6-02a5-33ef-6c61-6854da35d3a6@users.sourceforge.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:65086 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756221AbdDQPWf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 11:22:35 -0400
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 10:40:32 +0200

Replace the specification of two data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 61fd87d0a4ec..3bddb8fcd595 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -2024,7 +2024,7 @@ static int mvpp2_prs_vlan_add(struct mvpp2 *priv, unsigned short tpid, int ai,
 			goto error;
 		}
 
-		memset(pe, 0 , sizeof(struct mvpp2_prs_entry));
+		memset(pe, 0, sizeof(*pe));
 		mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_VLAN);
 		pe->index = tid;
 
@@ -2165,7 +2165,7 @@ static int mvpp2_prs_double_vlan_add(struct mvpp2 *priv, unsigned short tpid1,
 			goto error;
 		}
 
-		memset(pe, 0, sizeof(struct mvpp2_prs_entry));
+		memset(pe, 0, sizeof(*pe));
 		mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_VLAN);
 		pe->index = tid;
 
-- 
2.12.2
