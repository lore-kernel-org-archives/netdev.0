From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Access the replay notify functions via the
 registered callbacks
Date: Thu, 22 Mar 2012 19:30:43 -0400 (EDT)
Message-ID: <20120322.193043.2042143836874002556.davem@davemloft.net>
References: <20120322093613.GU29891@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180Ab2CVXbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:31:00 -0400
In-Reply-To: <20120322093613.GU29891@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 22 Mar 2012 10:36:13 +0100

> We call the wrong replay notify function when we use ESN replay
> handling. This leads to the fact that we don't send notifications
> if we use ESN. Fix this by calling the registered callbacks instead
> of xfrm_replay_notify().
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
