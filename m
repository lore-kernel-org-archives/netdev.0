From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Tue, 21 Sep 2004 19:42:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921194214.51d6b500.davem@davemloft.net>
References: <20040921210427.GB19575@kvack.org>
	<E1C9tj0-0003KE-00@gondolin.me.apana.org.au>
	<20040922011421.GE19575@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jchapman@katalix.com, netdev@oss.sgi.com,
        kleptog@svana.org, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20040922011421.GE19575@kvack.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2004 21:14:21 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

> On Wed, Sep 22, 2004 at 09:07:06AM +1000, Herbert Xu wrote:
> > Benjamin LaHaise <bcrl@kvack.org> wrote:
> > >
> > >> - Unlikely to integrate with the new native IPSEC stuff.
> > > 
> > > L2TP over IPSEC?  Are you insane?  You'd not be able to terminate more than 
> > > a couple of dozen connections over it. =-)
> > 
> > Why not? L2TP over IPsec is the only reason I'm looking at L2TP at all.
> 
> CPU load.  The main reason I was forced to revisit L2TP (imo, it's a 
> horrible protocol that suffers from too many bad decisions) was in its 
> role for terminating DSL.  In this case one expects to be able to have 
> tens of thousands of connections terminated by a single box, which 
> means pushing hundreds of megabits of traffic.  The overhead of crypto 
> operations in such a scenario makes it a far too costly choice.

I've heard of usage of both types described by Herbert and yourself,
and both are valid.

Therefore it's great that your scheme scales so well Ben, but it
has to support IPSEC properly as well.
