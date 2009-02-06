From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] forcedeth: enable msix to default
Date: Thu, 05 Feb 2009 21:02:37 -0800
Message-ID: <498BC46D.5080505@kernel.org>
References: <498BC3A8.9040203@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757358AbZBFFDs@vger.kernel.org>
In-Reply-To: <498BC3A8.9040203@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Impact: change default

msix and napic can work again

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
---
 drivers/net/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -862,7 +862,7 @@ enum {
 	NV_MSIX_INT_DISABLED,
 	NV_MSIX_INT_ENABLED
 };
-static int msix = NV_MSIX_INT_DISABLED;
+static int msix = NV_MSIX_INT_ENABLED;
 
 /*
  * DMA 64bit
