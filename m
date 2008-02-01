From: Doug Maxey <dwm@austin.ibm.com>
Subject: [PATCH 2/5] ehea: fix ethtool checkpatch complaints
Date: Thu, 31 Jan 2008 20:20:48 -0600
Message-ID: <1201832451-23634-3-git-send-email-dwm@austin.ibm.com>
References: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux PowerPC List <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>, Jan-Bernd Themann <themann@de.ibm.com>
To: Jeff Garzik <jgarzik@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Cc: Jan-Bernd Themann <themann@de.ibm.com>
Signed-off-by: Doug Maxey <dwm@austin.ibm.com>
---
 drivers/net/ehea/ehea_ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 679f40e..d768852 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -40,7 +40,7 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return ret;
 
 	if (netif_carrier_ok(dev)) {
-		switch(port->port_speed) {
+		switch (port->port_speed) {
 		case EHEA_SPEED_10M: cmd->speed = SPEED_10; break;
 		case EHEA_SPEED_100M: cmd->speed = SPEED_100; break;
 		case EHEA_SPEED_1G: cmd->speed = SPEED_1000; break;
@@ -78,7 +78,7 @@ static int ehea_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		goto doit;
 	}
 
-	switch(cmd->speed) {
+	switch (cmd->speed) {
 	case SPEED_10:
 		if (cmd->duplex == DUPLEX_FULL)
 			sp = H_SPEED_10M_F;
-- 
1.5.3.8
