From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] atm: fore200e.c:  Cleaning up uninitialized variables
Date: Sun,  1 Jun 2014 01:08:32 +0200
Message-ID: <1401577712-4447-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Rob Herring <robh+dt@kernel.org>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	Grant Likely <grant.likely@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a risk that the variable will be used without being initialized.

This was largely found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/atm/fore200e.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 204814e..d4725fc 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2780,7 +2780,7 @@ static struct pci_driver fore200e_pca_driver = {
 
 static int __init fore200e_module_init(void)
 {
-	int err;
+	int err = 0;
 
 	printk(FORE200E "FORE Systems 200E-series ATM driver - version " FORE200E_VERSION "\n");
 
-- 
1.7.10.4
