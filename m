From: domen@coderock.org
Subject: [patch 02/19] list_for_each: drivers-net-tulip-de4x5.c
Date: Wed, 12 Jan 2005 00:10:11 +0100
Message-ID: <20050111231011.DB77A1F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Hi.

s/for/list_for_each/
Compile tested.

Signed-off-by: Domen Puncer <domen@coderock.org>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/tulip/de4x5.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/tulip/de4x5.c~list-for-each-drivers_net_tulip_de4x5 drivers/net/tulip/de4x5.c
--- kj/drivers/net/tulip/de4x5.c~list-for-each-drivers_net_tulip_de4x5	2005-01-10 17:59:48.000000000 +0100
+++ kj-domen/drivers/net/tulip/de4x5.c	2005-01-10 17:59:48.000000000 +0100
@@ -2143,9 +2143,9 @@ srom_search(struct net_device *dev, stru
     u_long iobase = 0;                     /* Clear upper 32 bits in Alphas */
     int i, j, cfrv;
     struct de4x5_private *lp = netdev_priv(dev);
-    struct list_head *walk = &pdev->bus_list;
+    struct list_head *walk;
 
-    for (walk = walk->next; walk != &pdev->bus_list; walk = walk->next) {
+    list_for_each(walk, &pdev->bus_list) {
 	struct pci_dev *this_dev = pci_dev_b(walk);
 
 	/* Skip the pci_bus list entry */
_
