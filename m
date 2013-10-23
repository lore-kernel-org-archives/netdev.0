From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: always inline net_secret_init
Date: Wed, 23 Oct 2013 16:27:07 -0400 (EDT)
Message-ID: <20131023.162707.1471269899020780213.davem@davemloft.net>
References: <20131023064450.GA26236@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972Ab3JWU1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 16:27:09 -0400
In-Reply-To: <20131023064450.GA26236@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 23 Oct 2013 08:44:50 +0200

> Currently net_secret_init does not get inlined, so we always have a call
> to net_secret_init even in the fast path.
> 
> Let's specify net_secret_init as __always_inline so we have the nop in
> the fast-path without the call to net_secret_init and the unlikely path
> at the epilogue of the function.
> 
> jump_labels handle the inlining correctly.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.
