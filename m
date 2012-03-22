From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Remove unused xfrm_state from
 xfrm_state_check_space
Date: Thu, 22 Mar 2012 19:30:36 -0400 (EDT)
Message-ID: <20120322.193036.1098310626617665853.davem@davemloft.net>
References: <20120322093239.GT29891@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001Ab2CVXaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:30:52 -0400
In-Reply-To: <20120322093239.GT29891@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 22 Mar 2012 10:32:39 +0100

> The xfrm_state argument is unused in this function, so remove it.
> Also the name xfrm_state_check_space does not really match what this
> function does. It actually checks if we have enough head and tailroom
> on the skb. So we rename the function to xfrm_skb_check_space.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
