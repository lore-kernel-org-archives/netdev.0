From: "Randy.Dunlap" <rddunlap@xenotime.net>
Subject: [PATCH] skfddi: missing comma
Date: Mon, 23 Feb 2004 22:01:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223220156.1e618c03.rddunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm <akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Do you already have this?


// linux-263-feb23

diffstat:=
 drivers/net/skfp/skfddi.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff -Naurp ./drivers/net/skfp/skfddi.c~skfddi ./drivers/net/skfp/skfddi.c
--- ./drivers/net/skfp/skfddi.c~skfddi	2004-02-23 16:07:11.000000000 -0800
+++ ./drivers/net/skfp/skfddi.c	2004-02-23 21:44:12.000000000 -0800
@@ -262,7 +262,7 @@ static int skfp_init_one(struct pci_dev 
 #endif
 	err = pci_request_regions(pdev, "skfddi");
 	if (err) {
-		printk(KERN_ERR "Cannot allocate resources for adapter %s\n"
+		printk(KERN_ERR "Cannot allocate resources for adapter %s\n",
 				pci_name(pdev));
 		goto err_out1;
 	}


--
~Randy
