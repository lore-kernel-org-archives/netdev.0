From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Fri, 1 Apr 2005 17:20:07 -0800
Message-ID: <20050401172007.7296eced.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<424864CE.5060802@trash.net>
	<20050328233917.GB15369@gondor.apana.org.au>
	<424B40C2.90304@trash.net>
	<20050331004658.GA26395@gondor.apana.org.au>
	<20050331212325.5e996432.davem@davemloft.net>
	<20050402004956.GA24339@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050402004956.GA24339@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2 Apr 2005 10:49:56 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The second patch creates a dead lock since it does a nested read
> lock.  The solution is simply to get rid of xfrm_init_tempsel
> and call the afinfo version directly.

read locks nest even in the presence of pending writers
