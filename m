From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFC v1 1/7] net: phy: marvell: provide genphy suspend/resume
Date: Wed, 20 Nov 2013 21:21:47 +0100
Message-ID: <1384978913-8052-2-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Marvell PHYs support generic PHY suspend/resume, so provide those
callbacks to all marvell specific drivers.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David S. Miller <davem@davemloft.net>
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
