From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Make IPCOMP more resilient
Date: Thu, 31 Mar 2005 22:30:18 -0800
Message-ID: <20050331223018.74b433fe.davem@davemloft.net>
References: <20050326035853.GA25162@gondor.apana.org.au>
	<Xine.LNX.4.44.0503252337500.24726-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0503252337500.24726-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 25 Mar 2005 23:38:12 -0500 (EST)
James Morris <jmorris@redhat.com> wrote:

> On Sat, 26 Mar 2005, Herbert Xu wrote:
> 
> > In other words, we can let outbound IPCOMP always succeed.  In the cases
> > where it would currently fail we simply skip the IPCOMP transform.  This
> > makes IPCOMP slightly more resilient when memory is low and simplifies
> > the code quite a bit.
> 
> Good idea.
> 
> Acked-by: James Morris <jmorris@redhat.com>

Applied, thanks.
