From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Thu, 29 Jan 2015 22:26:31 +0000
Message-ID: <20150129222631.GB12928@casper.infradead.org>
References: <20150127231950.GA11374@gondor.apana.org.au>
 <E1YGFRA-0002yN-I0@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57891 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbA2W0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:26:37 -0500
Content-Disposition: inline
In-Reply-To: <E1YGFRA-0002yN-I0@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/15 at 10:20am, Herbert Xu wrote:
> Some existing rhashtable users get too intimate with it by walking
> the buckets directly.  This prevents us from easily changing the
> internals of rhashtable.
> 
> This patch adds the helpers rhashtable_walk_init/next/end which
> will replace these custom walkers.
> 
> They are meant to be usable for both procfs seq_file walks as well
> as walking by a netlink dump.  The iterator structure should fit
> inside a netlink dump cb structure, with at least one element to
> spare.
>   
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
