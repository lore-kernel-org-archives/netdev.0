From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] net: sysfs: add missing phys_port_id documentation
Date: Fri, 23 May 2014 16:35:40 -0700
Message-ID: <1400888142-5963-2-git-send-email-f.fainelli@gmail.com>
References: <1400888142-5963-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, therbert@google.com, edumazet@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:39873 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbaEWXfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 19:35:53 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so4779936pbc.16
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 16:35:53 -0700 (PDT)
In-Reply-To: <1400888142-5963-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation for the phys_port_id sysfs attribute of a network
device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/ABI/testing/sysfs-class-net | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-class-net b/Documentation/ABI/testing/sysfs-class-net
index d922060e455d..416c5d59f52e 100644
--- a/Documentation/ABI/testing/sysfs-class-net
+++ b/Documentation/ABI/testing/sysfs-class-net
@@ -169,6 +169,14 @@ Description:
 		"unknown", "notpresent", "down", "lowerlayerdown", "testing",
 		"dormant", "up".
 
+What:		/sys/class/net/<iface>/phys_port_id
+Date:		July 2013
+KernelVersion:	3.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface unique physical port identifier within
+		the NIC, as a string.
+
 What:		/sys/class/net/<iface>/speed
 Date:		October 2009
 KernelVersion:	2.6.33
-- 
1.9.1
