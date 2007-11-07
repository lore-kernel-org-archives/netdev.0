From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Rename "virtual ethernet device" to "virtual ethernet pair device".
Date: Wed, 7 Nov 2007 15:04:48 +1100
Message-ID: <200711071504.49112.rusty@rustcorp.com.au>
References: <200711071409.01000.rusty@rustcorp.com.au> <20071106.191906.127144742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37450 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754332AbXKGEEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 23:04:21 -0500
In-Reply-To: <20071106.191906.127144742.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 November 2007 14:19:06 David Miller wrote:
> If anything, the veth naming makes more sense than the IBM device
> cases.
>
> And that's why I decreed that last time this came up that the naming
> for veth was just fine.

OK, about the help text.  IMHO noone should be using "virtual
ethernet" unqualified, since there are multiple things that now refers to.

Here's a respin with just the help text changes:
==
Clarify "virtual ethernet device" to "virtual ethernet pair device".

It'd also be nice to mention "containers" somewhere in the help text
(I'm assuming that's what it's for?).

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5f800a6..cb581eb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -136,10 +136,11 @@ config TUN
 	  If you don't know what to use this for, you don't need it.
 
 config VETH
-	tristate "Virtual ethernet device"
+	tristate "Virtual ethernet pair device"
 	---help---
-	  The device is an ethernet tunnel. Devices are created in pairs. When
-	  one end receives the packet it appears on its pair and vice versa.
+	  This device is a local ethernet tunnel. Devices are created in pairs.
+	  When one end receives the packet it appears on its pair and vice
+	  versa.
 
 config NET_SB1000
 	tristate "General Instruments Surfboard 1000"
