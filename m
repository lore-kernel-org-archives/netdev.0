From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Thu, 21 Apr 2005 16:35:26 -0700
Message-ID: <20050421163526.7a29a76f.davem@davemloft.net>
References: <20050328233917.GB15369@gondor.apana.org.au>
	<424B40C2.90304@trash.net>
	<20050331004658.GA26395@gondor.apana.org.au>
	<20050331212325.5e996432.davem@davemloft.net>
	<20050402004956.GA24339@gondor.apana.org.au>
	<20050401172007.7296eced.davem@davemloft.net>
	<20050402020947.GA24998@gondor.apana.org.au>
	<42501E51.3000401@trash.net>
	<20050405103918.GA24863@gondor.apana.org.au>
	<4252EEA2.5020107@trash.net>
	<20050406022155.GA12952@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050406022155.GA12952@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Apr 2005 12:21:55 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Apr 05, 2005 at 10:01:38PM +0200, Patrick McHardy wrote:
> > 
> > Good idea, I didn't think of this. This patch is without replacement of
> > xfrm_init_tempsel(), it caused an "unused function" warning and, as I
> > mentioned before, I still need the function.
> 
> Thanks.  Just one more issue that I can think of, the check should
> only be done when tmpl->id.spi != 0.  Otherwise the presence of
> valid states with differing state selectors will prevent new
> sessions from starting up.

Is it really worthwhile, right now, to change that tmpl->id.daddr to
daddr?  That seems to be all that Patrick's most recent patch does.
