From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 3/4] staging: et131x: Add space after { in pci ID table
Date: Tue, 23 Sep 2014 20:41:13 +0100
Message-ID: <1411501274-2970-3-git-send-email-mark.einon@gmail.com>
References: <20140923100106.GE4657@distanz.ch>
 <1411501274-2970-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1411501274-2970-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 6539a8a..10f20b3 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -4397,7 +4397,7 @@ err_disable:
 static const struct pci_device_id et131x_pci_table[] = {
 	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_GIG), 0UL},
 	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_FAST), 0UL},
-	{0,}
+	{ 0,}
 };
 MODULE_DEVICE_TABLE(pci, et131x_pci_table);
 
-- 
2.1.0
