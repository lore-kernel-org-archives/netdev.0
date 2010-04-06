From: Ralf Baechle <ralf@linux-mips.org>
Subject: NET: sb1250: Fix compile warning in driver
Date: Tue, 6 Apr 2010 10:33:20 +0100
Message-ID: <20100406093320.GA31967@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:43278 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043Ab0DFK3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 06:29:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/sb1250-mac.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 9944e5d..142261b 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2664,7 +2664,6 @@ static int sbmac_close(struct net_device *dev)
 static int sbmac_poll(struct napi_struct *napi, int budget)
 {
 	struct sbmac_softc *sc = container_of(napi, struct sbmac_softc, napi);
-	struct net_device *dev = sc->sbm_dev;
 	int work_done;
 
 	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), budget, 1);
