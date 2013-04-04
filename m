From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V3] net: frag queue per hash bucket locking
Date: Thu, 04 Apr 2013 17:38:11 -0400 (EDT)
Message-ID: <20130404.173811.2079217765035237811.davem@davemloft.net>
References: <1365067672.12728.46.camel@localhost>
	<20130404093816.3613.42475.stgit@dragon>
	<1365092655.3308.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
	dborkman@redhat.com, hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764927Ab3DDViO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 17:38:14 -0400
In-Reply-To: <1365092655.3308.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Apr 2013 09:24:15 -0700

> On Thu, 2013-04-04 at 11:38 +0200, Jesper Dangaard Brouer wrote:
>> This patch implements per hash bucket locking for the frag queue
>> hash.  This removes two write locks, and the only remaining write
>> lock is for protecting hash rebuild.  This essentially reduce the
>> readers-writer lock to a rebuild lock.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
