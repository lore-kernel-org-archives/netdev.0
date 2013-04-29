From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2] net: increase frag hash size
Date: Mon, 29 Apr 2013 13:44:24 -0400 (EDT)
Message-ID: <20130429.134424.386873129090930198.davem@davemloft.net>
References: <20130424154822.16883.93014.stgit@dragon>
	<20130425194850.25609.46664.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, sergei.shtylyov@cogentembedded.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758298Ab3D2Ro0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 13:44:26 -0400
In-Reply-To: <20130425194850.25609.46664.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 25 Apr 2013 21:52:25 +0200

> Increase fragmentation hash bucket size to 1024 from old 64 elems.
> 
> After we increased the frag mem limits commit c2a93660 (net: increase
> fragment memory usage limits) the hash size of 64 elements is simply
> too small.  Also considering the mem limit is per netns and the hash
> table is shared for all netns.
> 
> For the embedded people, note that this increase will change the hash
> table/array from using approx 1 Kbytes to 16 Kbytes.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
