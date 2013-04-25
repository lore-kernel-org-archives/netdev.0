From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 2/4] net: increase frag hash size
Date: Thu, 25 Apr 2013 05:26:26 +0200
Message-ID: <20130425032626.GA21406@order.stressinduktion.org>
References: <20130424154624.16883.40974.stgit@dragon> <20130424154822.16883.93014.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33835 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118Ab3DYD01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 23:26:27 -0400
Content-Disposition: inline
In-Reply-To: <20130424154822.16883.93014.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 24, 2013 at 05:48:31PM +0200, Jesper Dangaard Brouer wrote:
> Increase fragmentation hash bucket size to 1024 from old 64 elems.
> 
> After we increased the frag mem limits (in commit v3.8-rc3-503-gc2a9366)
> the hash size of 64 elements is simply too small.  Also considering
> the mem limit is per netns and the hash table is shared for all netns.
> 
> For the embedded people, note that this increase will change the hash
> table/array from using approx 1 Kbytes to 16 Kbytes.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

If this change goes in and patch 1 does not get applied I do think we
can even lower the INETFRAGS_MAXDEPTH a bit (altough I don't see a need
for that because of stability issues)? It would just decrease latency
a bit in case someone attacks the hash buckets directly.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
