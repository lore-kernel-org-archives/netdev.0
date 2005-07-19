From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 6/8][ATM]: [ambassador] Fix the sparse warning "implicit cast to nocast type"
Date: Tue, 19 Jul 2005 16:45:59 -0400
Message-ID: <200507192045.j6JKjwZg027226@ginger.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

[ATM]: [ambassador] Fix the sparse warning "implicit cast to nocast type"

Signed-off-by: Victor Fusco <victor@cetuc.puc-rio.br>
Signed-off-by: Domen Puncer <domen@coderock.org>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>


---
commit 8e1e58dcc5ec7ea3c29c3ae38156afc2af150cea
tree e12e7c184de1170f179a17b4a3adf45986ef5a9e
parent 6e59c9c1673a7b31f00cc8dd79f1e11abf91be9a
author chas williams <chas@relax.(none)> Tue, 19 Jul 2005 15:08:43 -0400
committer chas williams <chas@relax.(none)> Tue, 19 Jul 2005 15:08:43 -0400

 drivers/atm/ambassador.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -794,7 +794,9 @@ static void drain_rx_pools (amb_dev * de
     drain_rx_pool (dev, pool);
 }
 
-static inline void fill_rx_pool (amb_dev * dev, unsigned char pool, int priority) {
+static inline void fill_rx_pool (amb_dev * dev, unsigned char pool,
+                                 unsigned int __nocast priority)
+{
   rx_in rx;
   amb_rxq * rxq;
   
