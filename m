From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] netlink: Use rhashtable walk iterator
Date: Thu, 29 Jan 2015 22:27:08 +0000
Message-ID: <20150129222708.GC12928@casper.infradead.org>
References: <20150127231950.GA11374@gondor.apana.org.au>
 <E1YGFRB-0002yg-Ry@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57902 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757044AbbA2W1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:27:09 -0500
Content-Disposition: inline
In-Reply-To: <E1YGFRB-0002yg-Ry@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/15 at 10:20am, Herbert Xu wrote:
> This patch gets rid of the manual rhashtable walk in netlink
> which touches rhashtable internals that should not be exposed.
> It does so by using the rhashtable iterator primitives.
> 
> In fact the existing code was very buggy.  Some sockets weren't
> shown at all while others were shown more than once.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
