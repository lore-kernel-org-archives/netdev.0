From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 01/13] fsl/fman: split lines over 80 characters
Date: Tue, 4 Oct 2016 10:32:47 +0300
Message-ID: <1475566379-5078-2-git-send-email-madalin.bucur@nxp.com>
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

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman_muram.c | 3 ++-
 drivers/net/ethernet/freescale/fman/fman_muram.h | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman_muram.c b/drivers/net/ethernet/freescale/fman/fman_muram.c
index 47394c4..5ec94d2 100644
--- a/drivers/net/ethernet/freescale/fman/fman_muram.c
+++ b/drivers/net/ethernet/freescale/fman/fman_muram.c
@@ -150,7 +150,8 @@ unsigned long fman_muram_alloc(struct muram_info *muram, size_t size)
  *
  * Free an allocated memory from FM-MURAM partition.
  */
-void fman_muram_free_mem(struct muram_info *muram, unsigned long offset, size_t size)
+void fman_muram_free_mem(struct muram_info *muram, unsigned long offset,
+			 size_t size)
 {
 	unsigned long addr = fman_muram_offset_to_vbase(muram, offset);
 
diff --git a/drivers/net/ethernet/freescale/fman/fman_muram.h b/drivers/net/ethernet/freescale/fman/fman_muram.h
index 889649a..453bf84 100644
--- a/drivers/net/ethernet/freescale/fman/fman_muram.h
+++ b/drivers/net/ethernet/freescale/fman/fman_muram.h
@@ -46,6 +46,7 @@ unsigned long fman_muram_offset_to_vbase(struct muram_info *muram,
 
 unsigned long fman_muram_alloc(struct muram_info *muram, size_t size);
 
-void fman_muram_free_mem(struct muram_info *muram, unsigned long offset, size_t size);
+void fman_muram_free_mem(struct muram_info *muram, unsigned long offset,
+			 size_t size);
 
 #endif /* __FM_MURAM_EXT */
-- 
2.1.0
