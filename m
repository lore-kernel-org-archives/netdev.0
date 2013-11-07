From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: icn: NULL dereference printing error message
Date: Thu, 7 Nov 2013 10:58:06 +0300
Message-ID: <20131107075806.GO21844@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	isdn4linux@listserv.isdn4linux.de, kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"card2" is NULL here so I have changed it to use "id2" instead of
"card2->interface.id".

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/icn/icn.c b/drivers/isdn/icn/icn.c
index e74df7c..53d487f 100644
--- a/drivers/isdn/icn/icn.c
+++ b/drivers/isdn/icn/icn.c
@@ -1580,8 +1580,7 @@ icn_addcard(int port, char *id1, char *id2)
 	}
 	if (!(card2 = icn_initcard(port, id2))) {
 		printk(KERN_INFO
-		       "icn: (%s) half ICN-4B, port 0x%x added\n",
-		       card2->interface.id, port);
+		       "icn: (%s) half ICN-4B, port 0x%x added\n", id2, port);
 		return 0;
 	}
 	card->doubleS0 = 1;
