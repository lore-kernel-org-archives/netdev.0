From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next v2 01/10] fsl/fman: parse result data is big endian
Date: Thu, 9 Mar 2017 16:36:56 +0200
Message-ID: <1489070225-7891-2-git-send-email-madalin.bucur@nxp.com>
References: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@nxp.com>, linux-kernel@vger.kernel.org,
 camelia.groza@nxp.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
 dan.carpenter@oracle.com
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
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

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.h b/drivers/net/ethernet/freescale/fman/fman.h
index 57aae8d..f53e147 100644
--- a/drivers/net/ethernet/freescale/fman/fman.h
+++ b/drivers/net/ethernet/freescale/fman/fman.h
@@ -134,14 +134,14 @@ enum fman_exceptions {
 struct fman_prs_result {
 	u8 lpid;		/* Logical port id */
 	u8 shimr;		/* Shim header result  */
-	u16 l2r;		/* Layer 2 result */
-	u16 l3r;		/* Layer 3 result */
+	__be16 l2r;		/* Layer 2 result */
+	__be16 l3r;		/* Layer 3 result */
 	u8 l4r;		/* Layer 4 result */
 	u8 cplan;		/* Classification plan id */
-	u16 nxthdr;		/* Next Header  */
-	u16 cksum;		/* Running-sum */
+	__be16 nxthdr;		/* Next Header  */
+	__be16 cksum;		/* Running-sum */
 	/* Flags&fragment-offset field of the last IP-header */
-	u16 flags_frag_off;
+	__be16 flags_frag_off;
 	/* Routing type field of a IPV6 routing extension header */
 	u8 route_type;
 	/* Routing Extension Header Present; last bit is IP valid */
-- 
2.1.0
