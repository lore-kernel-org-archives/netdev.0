From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Fri, 19 Sep 2014 16:03:51 -0400 (EDT)
Message-ID: <20140919.160351.1490731758266834534.davem@davemloft.net>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbaISUDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:03:53 -0400
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

Herbert please review.
