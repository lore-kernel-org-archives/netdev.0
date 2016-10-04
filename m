From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 10/13] fsl/fman: simplify redundant condition
Date: Tue, 4 Oct 2016 10:32:56 +0300
Message-ID: <1475566379-5078-11-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxdev.baldrick@gmail.com, linuxppc-dev@lists.ozlabs.org,
 davem@davemloft.net, linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Change suggested by David Binderman, thanks.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index 2278bbd..1fc1049 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2331,8 +2331,7 @@ int fman_set_mac_max_frame(struct fman *fman, u8 mac_id, u16 mfl)
 	 * or equal to the port's max
 	 */
 	if ((!fman->state->port_mfl[mac_id]) ||
-	    (fman->state->port_mfl[mac_id] &&
-	    (mfl <= fman->state->port_mfl[mac_id]))) {
+	    (mfl <= fman->state->port_mfl[mac_id])) {
 		fman->state->mac_mfl[mac_id] = mfl;
 	} else {
 		dev_warn(fman->dev, "%s: MAC max_frame_length is larger than Port max_frame_length\n",
-- 
2.1.0
