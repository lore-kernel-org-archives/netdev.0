From: wanlong.gao@gmail.com
Subject: [PATCH] X86:NET:Replaced a deprecated function .
Date: Mon,  4 Apr 2011 17:32:28 +0800
Message-ID: <1301909548-20031-1-git-send-email-wanlong.gao@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wanlong Gao <wanlong.gao@gmail.com>
To: linux@dominikbrodowski.net, davem@davemloft.net,
	padovan@profusion.mobi, joe@perches.com, marcel@holtmann.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wanlong Gao <wanlong.gao@gmail.com>

kernel_warning: pcmcia_request_exclusive_irq is deprecated .

Signed-off-by: Wanlong Gao <wanlong.gao@gmail.com>
---
 drivers/net/pcmcia/nmclan_cs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 76683d9..bf97231
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -625,7 +625,7 @@ static int nmclan_config(struct pcmcia_device *link)
   ret = pcmcia_request_io(link);
   if (ret)
 	  goto failed;
-  ret = pcmcia_request_exclusive_irq(link, mace_interrupt);
+  ret = __pcmcia_request_exclusive_irq(link, mace_interrupt);
   if (ret)
 	  goto failed;
   ret = pcmcia_enable_device(link);
-- 
1.7.3
