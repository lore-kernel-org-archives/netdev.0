From: Tushar Behera <tushar.behera@linaro.org>
Subject: [PATCH 10/14] atm: Removed redundant check on unsigned variable
Date: Fri, 16 Nov 2012 12:20:42 +0530
Message-ID: <1353048646-10935-11-git-send-email-tushar.behera@linaro.org>
References: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
Cc: patches@linaro.org, Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to check whether unsigned variable is less than 0.

CC: Chas Williams <chas@cmf.nrl.navy.mil>
CC: linux-atm-general@lists.sourceforge.net
CC: netdev@vger.kernel.org
Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
---
 drivers/atm/fore200e.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 361f5ae..fdd3fe7 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -972,7 +972,7 @@ int bsq_audit(int where, struct host_bsq* bsq, int scheme, int magn)
 		   where, scheme, magn, buffer->index, buffer->scheme);
 	}
 
-	if ((buffer->index < 0) || (buffer->index >= fore200e_rx_buf_nbr[ scheme ][ magn ])) {
+	if (buffer->index >= fore200e_rx_buf_nbr[ scheme ][ magn ]) {
 	    printk(FORE200E "bsq_audit(%d): queue %d.%d, out of range buffer index = %ld !\n",
 		   where, scheme, magn, buffer->index);
 	}
-- 
1.7.4.1
