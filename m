From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: optimize INET input path further
Date: Thu, 09 Dec 2010 20:07:58 -0800 (PST)
Message-ID: <20101209.200758.226778071.davem@davemloft.net>
References: <1291179847.2856.452.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754127Ab0LJEHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 23:07:30 -0500
In-Reply-To: <1291179847.2856.452.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Dec 2010 06:04:07 +0100

> Followup of commit b178bb3dfc30 (net: reorder struct sock fields)
> 
> Optimize INET input path a bit further, by :
> 
> 1) moving sk_refcnt close to sk_lock.
> 
> This reduces number of dirtied cache lines by one on 64bit arches (and
> 64 bytes cache line size).
> 
> 2) moving inet_daddr & inet_rcv_saddr at the beginning of sk
> 
> (same cache line than hash / family / bound_dev_if / nulls_node)
> 
> This reduces number of accessed cache lines in lookups by one, and dont
> increase size of inet and timewait socks.
> inet and tw sockets now share same place-holder for these fields. 
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
