From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Remove superfluous NULL pointer check
 in ipv6_local_rxpmtu
Date: Tue, 18 Oct 2011 23:51:53 -0400 (EDT)
Message-ID: <20111018.235153.1643663089613050557.davem@davemloft.net>
References: <20111011120102.GL1830@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab1JSDwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:52:04 -0400
In-Reply-To: <20111011120102.GL1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 11 Oct 2011 14:01:02 +0200

> The pointer to mtu_info is taken from the common buffer
> of the skb, thus it can't be a NULL pointer. This patch
> removes this check on mtu_info.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
