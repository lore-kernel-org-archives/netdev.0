From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 01/12] net: dsa: b53: Remove is_cpu_port()
Date: Tue, 19 Sep 2017 10:46:43 -0700
Message-ID: <20170919174654.2122-2-f.fainelli@gmail.com>
References: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34896 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751411AbdISRrG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:06 -0400
Received: by mail-wm0-f67.google.com with SMTP id e64so316831wmi.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:06 -0700 (PDT)
In-Reply-To: <20170919174654.2122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not used anywhere, so remove it.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_priv.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 01bd8cbe9a3f..7528b22aeb03 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -186,11 +186,6 @@ static inline int is58xx(struct b53_device *dev)
 #define B53_CPU_PORT_25	5
 #define B53_CPU_PORT	8
 
-static inline int is_cpu_port(struct b53_device *dev, int port)
-{
-	return dev->cpu_port;
-}
-
 struct b53_device *b53_switch_alloc(struct device *base,
 				    const struct b53_io_ops *ops,
 				    void *priv);
-- 
2.9.3
