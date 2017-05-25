From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/3] net: sysfs: Document "phydev" symbolic link
Date: Thu, 25 May 2017 09:21:42 -0700
Message-ID: <20170525162143.18319-3-f.fainelli@gmail.com>
References: <20170525162143.18319-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:32822 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165403AbdEYQVv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:21:51 -0400
Received: by mail-qt0-f196.google.com with SMTP id a46so30750092qte.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 09:21:50 -0700 (PDT)
In-Reply-To: <20170525162143.18319-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we link the network device to its PHY device, document this
sysfs symbolic link.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/ABI/testing/sysfs-class-net | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-class-net b/Documentation/ABI/testing/sysfs-class-net
index 668604fc8e06..6856da99b6f7 100644
--- a/Documentation/ABI/testing/sysfs-class-net
+++ b/Documentation/ABI/testing/sysfs-class-net
@@ -251,3 +251,11 @@ Contact:	netdev@vger.kernel.org
 Description:
 		Indicates the unique physical switch identifier of a switch this
 		port belongs to, as a string.
+
+What:		/sys/class/net/<iface>/phydev
+Date:		May 2017
+KernelVersion:	4.13
+Contact:	netdev@vger.kernel.org
+Description:
+		Symbolic link to the PHY device this network device is attached
+		to.
-- 
2.9.3
