From: jamal <hadi@cyberus.ca>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: 21 Sep 2004 23:03:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095822222.1046.16.camel@jzny.localdomain>
References: <20040921210427.GB19575@kvack.org>
	 <E1C9tj0-0003KE-00@gondolin.me.apana.org.au>
	 <20040922011421.GE19575@kvack.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jchapman@katalix.com,
        davem@davemloft.net, netdev@oss.sgi.com, kleptog@svana.org,
        mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20040922011421.GE19575@kvack.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 21:14, Benjamin LaHaise wrote:
> On Wed, Sep 22, 2004 at 09:07:06AM +1000, Herbert Xu wrote:

> CPU load.  
> The main reason I was forced to revisit L2TP (imo, it's a 
> horrible protocol that suffers from too many bad decisions) was in its 
> role for terminating DSL.  In this case one expects to be able to have 
> tens of thousands of connections terminated by a single box, which 
> means pushing hundreds of megabits of traffic.  The overhead of crypto 
> operations in such a scenario makes it a far too costly choice.

Bad excuse ;->
So use a crypto chip or do less connections and scale by distributing
etc. I have a feeling tehres nothing inherent in your code that stops
you from intergrating into ipsec.

cheers,
jamal
