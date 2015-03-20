From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: Round up/down min/max_size to
 ensure we respect limit
Date: Thu, 19 Mar 2015 21:02:46 -0400 (EDT)
Message-ID: <20150319.210246.835966531852513271.davem@davemloft.net>
References: <20150319214933.GA11937@gondor.apana.org.au>
	<20150319220248.GA12428@gondor.apana.org.au>
	<20150319223113.GD4190@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbCTBCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 21:02:51 -0400
In-Reply-To: <20150319223113.GD4190@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 19 Mar 2015 22:31:13 +0000

> Round up min_size respectively round down max_size to the next power
> of two to make sure we always respect the limit specified by the
> user. This is required because we compare the table size against the
> limit before we expand or shrink.
> 
> Also fixes a minor bug where we modified min_size in the params
> provided instead of the copy stored in struct rhashtable.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> Herbert: I'm fine with either approach. I figured you expected the
> user to take care of this, hence the added warning. This is perfectly
> fine with me me as well.

Applied, thanks a lot.
