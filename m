From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP] Modular IPv6 support in tcpdiag
Date: Wed, 3 Nov 2004 12:41:03 -0800
Message-ID: <20041103124103.13fe69d5.davem@davemloft.net>
References: <20041103094451.GA20220@gondor.apana.org.au>
	<20041103122050.50f6f556.davem@davemloft.net>
	<20041103203414.GB25279@gondor.apana.org.au>
	<20041103122941.71a5b440.davem@davemloft.net>
	<20041103204321.GA25470@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041103204321.GA25470@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 4 Nov 2004 07:43:21 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Nov 03, 2004 at 12:29:41PM -0800, David S. Miller wrote:
> >
> > > If I used that then it'll break when TCPDIAG is built-in and
> > > IPv6 is built as a module.
> > 
> > I see, you need the ipv6 tcp socket lookup symbols... hmmm.
> 
> Well it really should be turned into a plugin system.  However,
> since any effort to do that might as well be spent doing a
> generic socket info interface, I thought that we should just
> patch up tcp_diag and mark it as obsolete once we have a new
> interface.

I've put your patch in for now, but I don't know what I think
about deprecating an interface that took so much effort to get
people to use over the /proc/net/tcp{,6} stuff.
