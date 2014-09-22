From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2014-09-22
Date: Mon, 22 Sep 2014 16:43:55 -0400 (EDT)
Message-ID: <20140922.164355.932664395205178101.davem@davemloft.net>
References: <1411364320-5309-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaIVUn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:43:57 -0400
In-Reply-To: <1411364320-5309-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 22 Sep 2014 07:38:38 +0200

> We generate a blackhole or queueing route if a packet
> matches an IPsec policy but a state can't be resolved.
> Here we assume that dst_output() is called to kill
> these packets. Unfortunately this assumption is not
> true in all cases, so it is possible that these packets
> leave the system without the necessary transformations.
> 
> This pull request contains two patches to fix this issue:
> 
> 1) Fix for blackhole routed packets.
> 
> 2) Fix for queue routed packets.
> 
> Both patches are serious stable candidates.
> 
> Please pull or let me know if there are problems.

Pulled and queued up for -stable, thanks.
