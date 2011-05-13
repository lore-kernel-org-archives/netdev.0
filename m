From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] bonding,llc: Fix structure sizeof incompatibility
 for some PDUs
Date: Fri, 13 May 2011 15:15:35 -0400 (EDT)
Message-ID: <20110513.151535.291811874627297723.davem@davemloft.net>
References: <201105131204.29612.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com, joe@perches.com,
	fubar@us.ibm.com, andy@greyhouse.net, acme@ghostprotocols.net
To: vitas@nppfactor.kiev.ua
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab1EMTQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 15:16:15 -0400
In-Reply-To: <201105131204.29612.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Date: Fri, 13 May 2011 12:04:29 +0300

> With some combinations of arch/compiler (e.g. arm-linux-gcc) the sizeof 
> operator on structure returns value greater than expected. In cases when the 
> structure is used for mapping PDU fields it may lead to unexpected results 
> (such as holes and alignment problems in skb data). __packed prevents this 
> undesired behavior.
> 
> Signed-off-by: Vitalii Demianets <vitas@nppfactor.kiev.ua>

Applied, thanks.
