From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Tue, 21 Sep 2004 21:14:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922011421.GE19575@kvack.org>
References: <20040921210427.GB19575@kvack.org> <E1C9tj0-0003KE-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, davem@davemloft.net, netdev@oss.sgi.com,
        kleptog@svana.org, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1C9tj0-0003KE-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2004 at 09:07:06AM +1000, Herbert Xu wrote:
> Benjamin LaHaise <bcrl@kvack.org> wrote:
> >
> >> - Unlikely to integrate with the new native IPSEC stuff.
> > 
> > L2TP over IPSEC?  Are you insane?  You'd not be able to terminate more than 
> > a couple of dozen connections over it. =-)
> 
> Why not? L2TP over IPsec is the only reason I'm looking at L2TP at all.

CPU load.  The main reason I was forced to revisit L2TP (imo, it's a 
horrible protocol that suffers from too many bad decisions) was in its 
role for terminating DSL.  In this case one expects to be able to have 
tens of thousands of connections terminated by a single box, which 
means pushing hundreds of megabits of traffic.  The overhead of crypto 
operations in such a scenario makes it a far too costly choice.

		-ben
