From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v2 4/7] via-velocity: Change DMA_LENGTH_DEF (from the VIA
 driver)
Date: Mon, 23 Nov 2009 15:31:26 +0100
Message-ID: <20091123153126.4ed0b907@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:37145 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753967AbZKWOb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 09:31:27 -0500
In-Reply-To: <20091123152724.2871cf4d@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VIA driver has changed the default for the DMA_LENGTH_DEF parameter.
Together with adaptive interrupt supression and NAPI support, this
improves performance quite a bit

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 668cdf6..06a6d80 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -275,7 +275,7 @@ VELOCITY_PARAM(rx_thresh, "Receive fifo threshold");
 
 #define DMA_LENGTH_MIN  0
 #define DMA_LENGTH_MAX  7
-#define DMA_LENGTH_DEF  0
+#define DMA_LENGTH_DEF  6
 
 /* DMA_length[] is used for controlling the DMA length
    0: 8 DWORDs
-- 
1.6.0.4

