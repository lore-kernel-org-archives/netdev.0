From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/8] net: dsa: add missing netdevice.h include
Date: Mon, 12 Jan 2015 13:57:39 -0800
Message-ID: <1421099866-3184-2-git-send-email-f.fainelli@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59952 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbALV5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:57:54 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so34382844pad.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:57:53 -0800 (PST)
In-Reply-To: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dsa_priv.h contains function prototypes which use a netdev_tx_t return
type, include netdevice.h to get that definition.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa_priv.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index dc9756d3154c..e560ae53996c 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -11,6 +11,7 @@
 #ifndef __DSA_PRIV_H
 #define __DSA_PRIV_H
 
+#include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 
-- 
2.1.0
