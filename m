From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-09-26
Date: Mon, 30 Sep 2013 15:12:20 -0400 (EDT)
Message-ID: <20130930.151220.415236832608034525.davem@davemloft.net>
References: <1380185923-8976-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272Ab3I3TMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:12:22 -0400
In-Reply-To: <1380185923-8976-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 26 Sep 2013 10:58:41 +0200

> Two patches that are left from the last development cycle.
> Manual merging of include/net/xfrm.h is needed. The conflict
> can be solved as it is currently done in linux-next.
> 
> 1) We announce the creation of temporary acquire state via an asyc event,
>    so the deletion should be annunced too. From Nicolas Dichtel.
> 
> 2) The VTI tunnels do not real tunning, they just provide a routable
>    IPsec tunnel interface. So introduce and use xfrm_tunnel_notifier
>    instead of xfrm_tunnel for xfrm tunnel mode callback. From Fan Du.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot!
