From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] flowcache: restore a single flow_cache
 kmem_cache
Date: Mon, 10 Mar 2014 21:45:35 -0400 (EDT)
Message-ID: <20140310.214535.840011845120466987.davem@davemloft.net>
References: <531D60EF.9000501@windriver.com>
	<1394459069.3607.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394460547.3607.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, moorray3@wp.pl, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbaCKBpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 21:45:44 -0400
In-Reply-To: <1394460547.3607.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Mar 2014 07:09:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> It is not legal to create multiple kmem_cache having the same name.
> 
> flowcache can use a single kmem_cache, no need for a per netns
> one.
> 
> Fixes: ca925cf1534e ("flowcache: Make flow cache name space aware")
> Reported-by: Jakub Kicinski <moorray3@wp.pl>
> Tested-by: Jakub Kicinski <moorray3@wp.pl>
> Tested-by: Fan Du <fan.du@windriver.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'll apply this directly to net-next, thanks Eric!
