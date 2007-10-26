From: Roel Kluin <12o3l@tiscali.nl>
Subject: Re: [PATCH 1] net: fix and typo's
Date: Fri, 26 Oct 2007 21:54:54 +0200
Message-ID: <4722460E.4010201@tiscali.nl>
References: <47221EBE.3070109@tiscali.nl> <47222932.80408@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out2.tiscali.nl ([195.241.79.177]:46218 "EHLO
	smtp-out2.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbXJZTzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 15:55:05 -0400
In-Reply-To: <47222932.80408@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:

> Ack this e1000e change here!

> (PS since there was only 1 netdriver patch here and the rest is wireless, I would
> have suggested splitting this patch up in two and sending them to the wireless
> maintainer and netdevice maintainer separately. But I'm sure this will get picked
> up anyway.)

Ok, I've split the patch and sent the rest to wireless. Here's this single fix again
you acked.

--
        Fix priority mistakes similar to '!x & y'
    
        Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index cf70522..14141a5 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -283,7 +283,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
 			adapter->flags &= ~FLAG_HAS_WOL;
 		/* quad ports only support WoL on port A */
 		if (adapter->flags & FLAG_IS_QUAD_PORT &&
-		    (!adapter->flags & FLAG_IS_QUAD_PORT_A))
+		    (!(adapter->flags & FLAG_IS_QUAD_PORT_A)))
 			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
 
