From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/11] net: mitigating kmem_cache slowpath and
 BoF discussion patches
Date: Sun, 07 Feb 2016 14:25:26 -0500 (EST)
Message-ID: <20160207.142526.1252110536030712971.davem@davemloft.net>
References: <20151023124451.17364.14594.stgit@firesoul>
	<20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cl@linux.com, tom@herbertland.com,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbcBGTZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:25:31 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 02 Feb 2016 22:11:28 +0100

> This patchset is relevant for my NetDev 1.1 "Network Performance BoF" [1].
> 
> The first 4 patches, is a repost[2], for the first real use-case of
> kmem_cache bulk alloc and free API.  They were adjusted slightly to
> accomodate my last slab API changes.  They should be ready for
> inclusion in net-next, as the needed MM tree are avail in net-next.
> 
> Patch 5 is also enabling the SKB bulk API for mlx5.
> 
> Thus, patches 1-5 should be ready for net-next.
> 
> After patch 5, the experimental patches begin, which is Prove-of-Concept
> code for what we will be discussing during the Network Performance BoF [1]
> 
> [1] http://netdevconf.org/1.1/bof-network-performance-bof-jesper-dangaard-brouer.html
> [2] http://thread.gmane.org/gmane.linux.network/384302/

Very exciting work, indeed!

Jesper, why don't you resubmit just the first three patches as a
group?  They seem a lot less controversial and as Alexei said, stand
on their own.

Thanks.
