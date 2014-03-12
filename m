From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] flowcache: Fix resource leaks on namespace
 exit.
Date: Wed, 12 Mar 2014 15:31:33 -0400 (EDT)
Message-ID: <20140312.153133.1311495376693560386.davem@davemloft.net>
References: <20140311153029.1de9d6e9@north>
	<20140312083827.GE32371@secunet.com>
	<20140312084317.GF32371@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: moorray3@wp.pl, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	fan.du@windriver.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaCLTbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 15:31:34 -0400
In-Reply-To: <20140312084317.GF32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 12 Mar 2014 09:43:17 +0100

> We leak an active timer, the hotcpu notifier and all allocated
> resources when we exit a namespace. Fix this by introducing a
> flow_cache_fini() function where we release the resources before
> we exit.
> 
> Fixes: ca925cf1534e ("flowcache: Make flow cache name space aware")
> Reported-by: Jakub Kicinski <moorray3@wp.pl>
> Tested-by: Jakub Kicinski <moorray3@wp.pl>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Fan Du <fan.du@windriver.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks everyone.
