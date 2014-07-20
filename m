From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 01/30] dlci: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:16:09 +0200
Message-ID: <1405865801-18806-2-git-send-email-fabf@skynet.be>
References: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wan/dlci.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 19f7cb2..7ebfafe 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -255,7 +255,6 @@ static int dlci_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				return -EINVAL;
 
 			return dlci_config(dev, ifr->ifr_data, cmd == DLCI_GET_CONF);
-			break;
 
 		default: 
 			return -EOPNOTSUPP;
-- 
1.9.1
