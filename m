From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2/2] Modularise xfrm_tunnel
Date: Thu, 19 Aug 2004 07:25:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819072525.430f00bd.davem@redhat.com>
References: <20040819113841.GA13872@gondor.apana.org.au>
	<20040819114050.GA16049@gondor.apana.org.au>
	<20040819114359.GA16189@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040819114359.GA16189@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Aug 2004 21:43:59 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Aug 19, 2004 at 09:40:50PM +1000, herbert wrote:
> > 
> > This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
> > modules.
> > 
> > This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
> > which are modules themselves.  It also means that distros can cut
> > down on there core kernel size when compiling with IPsec support.
> 
> I missed xfrm_export.c in that patch.  Here is the corrected version.

Looks great, applied.

I suppose you're making your way towards proper TOS tunnel handling
and the other fixes we spoke of?
