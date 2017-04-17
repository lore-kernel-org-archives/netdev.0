From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 15/25] net: mvpp2: Adjust three error messages
Date: Mon, 17 Apr 2017 17:25:23 +0200
Message-ID: <06441317-68c3-f48e-33ea-638c80c1f17f@users.sourceforge.net>
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
Date: Mon, 17 Apr 2017 11:20:41 +0200

Use the word "failed" in the string for three function calls.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 89237abf386d..717d79dcb6aa 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6094,7 +6094,7 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
 	mvpp2_ingress_enable(port);
 	return 0;
 log_error:
-	netdev_err(dev, "fail to change MAC address\n");
+	netdev_err(dev, "failed to change MAC address\n");
 	return err;
 }
 
@@ -6142,7 +6142,7 @@ static int mvpp2_change_mtu(struct net_device *dev, int mtu)
 
 	return 0;
 log_error:
-	netdev_err(dev, "fail to change MTU\n");
+	netdev_err(dev, "failed to change MTU\n");
 	return err;
 }
 
@@ -6311,7 +6311,7 @@ static int mvpp2_ethtool_set_ringparam(struct net_device *dev,
 err_clean_rxqs:
 	mvpp2_cleanup_rxqs(port);
 err_out:
-	netdev_err(dev, "fail to change ring parameters");
+	netdev_err(dev, "failed to change ring parameters");
 	return err;
 }
 
-- 
2.12.2
