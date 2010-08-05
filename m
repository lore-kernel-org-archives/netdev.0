From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/42] drivers/net/wan: Adjust confusing if indentation
Date: Thu, 5 Aug 2010 22:17:00 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052216400.31692@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Indent the branch of an if.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wan/c101.c      |    2 +-
 drivers/net/wan/n2.c        |    2 +-
 drivers/net/wan/pci200syn.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index 0bd898c..4ac85a0 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -264,7 +264,7 @@ static int c101_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		    new_line.clock_type != CLOCK_TXFROMRX &&
 		    new_line.clock_type != CLOCK_INT &&
 		    new_line.clock_type != CLOCK_TXINT)
-		return -EINVAL;	/* No such clock setting */
+			return -EINVAL;	/* No such clock setting */
 
 		if (new_line.loopback != 0 && new_line.loopback != 1)
 			return -EINVAL;
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index 5394b51..7a3720f 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -282,7 +282,7 @@ static int n2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		    new_line.clock_type != CLOCK_TXFROMRX &&
 		    new_line.clock_type != CLOCK_INT &&
 		    new_line.clock_type != CLOCK_TXINT)
-		return -EINVAL;	/* No such clock setting */
+			return -EINVAL;	/* No such clock setting */
 
 		if (new_line.loopback != 0 && new_line.loopback != 1)
 			return -EINVAL;
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index e2cff64..fd73759 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -220,7 +220,7 @@ static int pci200_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		    new_line.clock_type != CLOCK_TXFROMRX &&
 		    new_line.clock_type != CLOCK_INT &&
 		    new_line.clock_type != CLOCK_TXINT)
-		return -EINVAL;	/* No such clock setting */
+			return -EINVAL;	/* No such clock setting */
 
 		if (new_line.loopback != 0 && new_line.loopback != 1)
 			return -EINVAL;
