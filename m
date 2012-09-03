From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fq_codel: dont reinit flow state
Date: Mon, 03 Sep 2012 14:37:31 -0400 (EDT)
Message-ID: <20120903.143731.1529957529578802591.davem@davemloft.net>
References: <1346505597.7996.76.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave.taht@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754980Ab2ICShd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 14:37:33 -0400
In-Reply-To: <1346505597.7996.76.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 01 Sep 2012 06:19:57 -0700

> When fq_codel builds a new flow, it should not reset codel state.
> 
> Codel algo needs to get previous values (lastcount, drop_next) to get
> proper behavior.
> 
> Signed-off-by: Dave Taht <dave.taht@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to 'net', thanks.
