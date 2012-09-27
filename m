From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: struct napi_struct fields reordering
Date: Thu, 27 Sep 2012 19:30:19 -0400 (EDT)
Message-ID: <20120927.193019.1474568650614437836.davem@davemloft.net>
References: <1348679267.5093.419.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab2I0XaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:30:21 -0400
In-Reply-To: <1348679267.5093.419.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Sep 2012 19:07:47 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Remove two holes on 64bit arches, and put dev_list at the end of
> napi_struct since its not used in fast path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
