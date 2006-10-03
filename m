From: James Morris <jmorris@namei.org>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Tue, 3 Oct 2006 09:56:05 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610030955400.19772@d.namei>
References: <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net>
 <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net>
 <20060901070557.GA15731@gondor.apana.org.au> <20060901162248.GI19284@ripe.net>
 <20060925121530.GC18667@gondor.apana.org.au> <20060926112122.GU22330@ripe.net>
 <20060928003829.GA8952@gondor.apana.org.au> <20060928084018.GA15141@ripe.net>
 <20061003054935.GA23963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: cagri coltekin <cagri@ripe.net>, netdev@vger.kernel.org,
	davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:8859 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750853AbWJCN4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 09:56:08 -0400
To: Herbert Xu <herbert.xu@redhat.com>
In-Reply-To: <20061003054935.GA23963@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2006, Herbert Xu wrote:

> On Thu, Sep 28, 2006 at 10:40:18AM +0200, cagri coltekin wrote:
> >
> > No. Bug is the first after boot:
> 
> OK, I think I've got the right bug this time.
> 
> [UDP6]: Fix flowi clobbering
> 
> The udp6_sendmsg function uses a shared buffer to store the
> flow without taking any locks.  This leads to races with SMP.
> This patch moves the flowi object onto the stack.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Nice catch.

Acked-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
