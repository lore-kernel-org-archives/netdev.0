From: janitor@sternwelten.at
Subject: [patch 3/4]  list_for_each: 	drivers-net-tulip-de4x5.c
Date: Sat, 20 Nov 2004 03:45:06 +0100
Message-ID: <E1CVLFL-0002GJ-8v@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, domen@coderock.org
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

---

 linux-2.6.10-rc2-bk4-max/drivers/net/tulip/de4x5.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/tulip/de4x5.c~list-for-each-drivers_net_tulip_de4x5 drivers/net/tulip/de4x5.c
--- linux-2.6.10-rc2-bk4/drivers/net/tulip/de4x5.c~list-for-each-drivers_net_tulip_de4x5	2004-11-19 17:15:18.000000000 +0100
+++ linux-2.6.10-rc2-bk4-max/drivers/net/tulip/de4x5.c	2004-11-19 17:15:18.000000000 +0100
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
