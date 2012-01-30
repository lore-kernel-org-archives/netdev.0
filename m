From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 14/16] hamradio: fix incompatible pointer in module parameter
Date: Mon, 30 Jan 2012 23:00:18 +0100
Message-ID: <1327960820-11867-15-git-send-email-danny.kukawka@bisect.de>
References: <1327960820-11867-1-git-send-email-danny.kukawka@bisect.de>
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thomas Sailer <t.sailer@alumni.ethz.ch>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1327960820-11867-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed 'warning: return from incompatible pointer type' related
to module parameters.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/hamradio/baycom_epp.c |    2 +-
 drivers/net/hamradio/baycom_par.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 9537aaa..49b8b58 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -1162,7 +1162,7 @@ static void baycom_probe(struct net_device *dev)
 /*
  * command line settable parameters
  */
-static const char *mode[NR_PORTS] = { "", };
+static char *mode[NR_PORTS] = { "", };
 static int iobase[NR_PORTS] = { 0x378, };
 
 module_param_array(mode, charp, NULL, 0);
diff --git a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
index 279d229..f1aea0c 100644
--- a/drivers/net/hamradio/baycom_par.c
+++ b/drivers/net/hamradio/baycom_par.c
@@ -477,7 +477,7 @@ static int baycom_ioctl(struct net_device *dev, struct ifreq *ifr,
 /*
  * command line settable parameters
  */
-static const char *mode[NR_PORTS] = { "picpar", };
+static char *mode[NR_PORTS] = { "picpar", };
 static int iobase[NR_PORTS] = { 0x378, };
 
 module_param_array(mode, charp, NULL, 0);
-- 
1.7.7.3

