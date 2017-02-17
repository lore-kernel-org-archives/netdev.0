From: Valentin Longchamp <valentin.longchamp@keymile.com>
Subject: [PATCH] net/wan: add MODULE_LICENSE for fsl_ucc_hdlc
Date: Fri, 17 Feb 2017 11:31:22 +0100
Message-ID: <1487327482-26482-1-git-send-email-valentin.longchamp@keymile.com>
Cc: Valentin Longchamp <valentin.longchamp@keymile.com>,
 linuxppc-dev@lists.ozlabs.org
To: qiang.zhao@nxp.com, netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
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

It is required to build it as a module.

Signed-off-by: Valentin Longchamp <valentin.longchamp@keymile.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index e38ce4d..1f38c06 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -1175,3 +1175,4 @@ static int ucc_hdlc_remove(struct platform_device *pdev)
 };
 
 module_platform_driver(ucc_hdlc_driver);
+MODULE_LICENSE("GPL");
-- 
1.8.3.1
