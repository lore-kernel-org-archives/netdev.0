From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 07/12] NET: de4x5: Fix section mismatch
Date: Sun, 26 Jun 2011 12:28:44 +0100
Message-ID: <5ef17c7883b7a81d7f321f88a36f6dfe7f40bdd2.1309182743.git.ralf@linux-mips.org>
References: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Cc: Grant Grundler <grundler@parisc-linux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARNING: drivers/net/tulip/de4x5.o(.data+0x34): Section mismatch in reference from the variable de4x5_eisa_driver to the function .init.text:de4x5_eisa_probe()
The variable de4x5_eisa_driver references
the function __init de4x5_eisa_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Grant Grundler <grundler@parisc-linux.org>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
---
 drivers/net/tulip/de4x5.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index efaa1d6..ea473b6 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1995,7 +1995,7 @@ SetMulticastFilter(struct net_device *dev)
 
 static u_char de4x5_irq[] = EISA_ALLOWED_IRQ_LIST;
 
-static int __init de4x5_eisa_probe (struct device *gendev)
+static int __devinit de4x5_eisa_probe (struct device *gendev)
 {
 	struct eisa_device *edev;
 	u_long iobase;
-- 
1.7.4.4
