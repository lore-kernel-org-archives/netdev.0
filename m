From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Mon, 22 Sep 2014 14:10:48 -0400 (EDT)
Message-ID: <20140922.141048.2225879376615599480.davem@davemloft.net>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220AbaIVSKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:10:55 -0400
In-Reply-To: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 17 Sep 2014 10:08:08 +0200

> Since commit 412ca1550cbe ("macvlan: Move broadcasts into a work queue"), the
> driver uses tx_queue_len of the master device as the limit of packets enqueuing.
> Problem is that virtual drivers have this value set to 0, thus all broadcast
> packets were rejected.
> Because tx_queue_len was arbitrarily chosen, I replace it with a static limit
> of 1000 (also arbitrarily chosen).
> 
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> Reported-by: Thibaut Collet <thibaut.collet@6wind.com>
> Suggested-by: Thibaut Collet <thibaut.collet@6wind.com>
> Tested-by: Thibaut Collet <thibaut.collet@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable.

Longer term we should come up with something a little bit nicer.
