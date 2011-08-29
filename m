From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH -next] net: fix Makefile typos & build errors
Date: Mon, 29 Aug 2011 11:49:40 -0700
Message-ID: <20110829114940.4d29febc.rdunlap@xenotime.net>
References: <20110829161907.19232776e65389dea1caa7e8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110829161907.19232776e65389dea1caa7e8@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix many (randconfig) PPP build errors by fixing typos in
drivers/net/Makefile.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/Makefile |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-next-20110829.orig/drivers/net/Makefile
+++ linux-next-20110829/drivers/net/Makefile
@@ -35,7 +35,7 @@ obj-$(CONFIG_HIPPI) += hippi/
 obj-$(CONFIG_HAMRADIO) += hamradio/
 obj-$(CONFIG_IRDA) += irda/
 obj-$(CONFIG_PLIP) += plip/
-onj-$(CONFIG_PPP) += ppp/
+obj-$(CONFIG_PPP) += ppp/
 obj-$(CONFIG_PPP_ASYNC) += ppp/
 obj-$(CONFIG_PPP_BSDCOMP) += ppp/
 obj-$(CONFIG_PPP_DEFLATE) += ppp/
@@ -44,10 +44,10 @@ obj-$(CONFIG_PPP_SYNC_TTY) += ppp/
 obj-$(CONFIG_PPPOE) += ppp/
 obj-$(CONFIG_PPPOL2TP) += ppp/
 obj-$(CONFIG_PPTP) += ppp/
-onj-$(CONFIG_SLIP) += slip/
+obj-$(CONFIG_SLIP) += slip/
 obj-$(CONFIG_SLHC) += slip/
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-onj-$(CONFIG_SLIP) += slip/
+obj-$(CONFIG_SLIP) += slip/
 obj-$(CONFIG_SUNGEM_PHY) += sungem_phy.o
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
