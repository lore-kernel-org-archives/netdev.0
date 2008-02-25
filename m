From: Patrick McHardy <kaber@trash.net>
Subject: [MACVLAN]: Update Kconfig to refer to iproute
Date: Mon, 25 Feb 2008 15:51:35 +0100
Message-ID: <47C2D5F7.4070503@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030103010709070303040807"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:48539 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667AbYBYOvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 09:51:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030103010709070303040807
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------030103010709070303040807
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[MACVLAN]: Update Kconfig to refer to iproute

Since the macvlan release I had at least 5 users asking how to configure
it since the old userspace tool doesn't work with the version in the
kernel. Add a pointer to the Kconfig help.

Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f337800..f333c11 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -90,6 +90,11 @@ config MACVLAN
 	  This allows one to create virtual interfaces that map packets to
 	  or from specific MAC addresses to a particular interface.
 
+	  Macvlan devices can be added using the "ip" command from the
+	  iproute2 package starting with the iproute2-2.6.23 release:
+
+	  "ip link add link <real dev> [ address MAC ] [ NAME ] type macvlan"
+
 	  To compile this driver as a module, choose M here: the module
 	  will be called macvlan.
 

--------------030103010709070303040807--
