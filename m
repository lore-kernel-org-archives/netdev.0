From: David Miller <davem@davemloft.net>
Subject: Re: [1/13] bridge: Add IGMP snooping support
Date: Sun, 28 Feb 2010 00:52:58 -0800 (PST)
Message-ID: <20100228.005258.70198395.davem@davemloft.net>
References: <20100226153410.GA26419@gondor.apana.org.au>
	<20100228054012.GA7583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42412
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031496Ab0B1Iwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 03:52:41 -0500
In-Reply-To: <20100228054012.GA7583@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 28 Feb 2010 13:40:12 +0800

> This is a repost of exactly the same series in order to get them
> back into patchworks.  I hope I have resolved your concerns about
> patch number 2.  Let me know if you still have any further questions.

Looks good applied.  I had to add the following patch to fix some
Kconfig issues.

Thanks.

bridge: Make IGMP snooping depend upon BRIDGE.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bridge/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
index 78dd549..19a6b96 100644
--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -34,6 +34,7 @@ config BRIDGE
 
 config BRIDGE_IGMP_SNOOPING
 	bool "IGMP snooping"
+	depends on BRIDGE
 	default y
 	---help---
 	  If you say Y here, then the Ethernet bridge will be able selectively
-- 
1.6.6.1

