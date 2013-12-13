From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v2 2/5] net: phy: marvell: provide genphy suspend/resume
Date: Fri, 13 Dec 2013 10:20:26 +0100
Message-ID: <1386926429-28818-3-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marvell PHYs support generic PHY suspend/resume, so provide those
callbacks to all marvell specific drivers.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/marvell.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 2e3c778e..bd37e45 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -894,6 +894,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -907,6 +909,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -920,6 +924,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -933,6 +939,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = {.owner = THIS_MODULE,},
 	},
 	{
@@ -946,6 +954,8 @@ static struct phy_driver marvell_drivers[] = {
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.did_interrupt = &m88e1121_did_interrupt,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -961,6 +971,8 @@ static struct phy_driver marvell_drivers[] = {
 		.did_interrupt = &m88e1121_did_interrupt,
 		.get_wol = &m88e1318_get_wol,
 		.set_wol = &m88e1318_set_wol,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -974,6 +986,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -987,6 +1001,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1000,6 +1016,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1013,6 +1031,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1026,6 +1046,8 @@ static struct phy_driver marvell_drivers[] = {
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.did_interrupt = &m88e1121_did_interrupt,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
 		.driver = { .owner = THIS_MODULE },
 	},
 };
-- 
1.7.2.5
