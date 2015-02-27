From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] rhashtable updates
Date: Fri, 27 Feb 2015 16:06:36 -0500 (EST)
Message-ID: <20150227.160636.801575476496804200.davem@davemloft.net>
References: <cover.1424877322.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787AbbB0VGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 16:06:39 -0500
In-Reply-To: <cover.1424877322.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 25 Feb 2015 16:31:52 +0100

> As discussed, I'm sending out rhashtable fixups for -net.
> 
> I have a couple of more patches I was working on last week pending,
> i.e. to get rid of ht->nelems and ht->shift atomic operations which
> speed-up pure insertions/deletions, e.g. on my laptop I have 2 threads,
> inserting 7M entries each, that will reduce insertion time from ~1,450 ms
> to 865 ms (performance should even be better after removing the
> grow/shrink indirections). I guess that however is rather something
> for net-next.

Series applied, thanks.
