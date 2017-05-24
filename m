From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: sysfs: Document "phydev" symbolic link
Date: Wed, 24 May 2017 12:33:53 -0700
Message-ID: <20170524193354.10739-3-f.fainelli@gmail.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34014 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030907AbdEXTeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:34:08 -0400
Received: by mail-wr0-f194.google.com with SMTP id 6so10681602wrb.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 12:34:07 -0700 (PDT)
In-Reply-To: <20170524193354.10739-1-f.fainelli@gmail.com>
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
