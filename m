From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 13:36:11 -0800
Message-ID: <20050114133611.69ff0bb2.davem@davemloft.net>
References: <20050113171234.3fde0925.davem@davemloft.net>
	<20050114012504.GF6309@krispykreme.ozlabs.ibm.com>
	<20050113201914.46b7c4a2.davem@davemloft.net>
	<20050114111648.GA27964@gondor.apana.org.au>
	<20050114120322.GA28449@gondor.apana.org.au>
	<20050114110352.23c94ab9.davem@davemloft.net>
	<20050114203452.GA1277@gondor.apana.org.au>
	<20050114132757.4ca3153a.davem@davemloft.net>
	<20050114213829.GA12454@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050114213829.GA12454@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Jan 2005 08:38:29 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Jan 14, 2005 at 01:27:57PM -0800, David S. Miller wrote:
> > 
> > You missed the whole problem.
> > 
> > It has nothing to do with the MSS changing.
> 
> However if the MSS does change then it can cause the same symptoms.
> In fact the MSS can easily increase when TSO is enabled since it
> increases as the RCV window is opened up.

MSS changes are handled _transparently_ if we do the adjustments
as we actaully add data to the packet.  We always account what is
actually put into the packet in this way.

That's why I made the fix the way that I did.
