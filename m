From: "David S. Miller" <davem@redhat.com>
Subject: Re: ip_route_me_harder -> xfrm_lookup
Date: Mon, 8 Mar 2004 11:58:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308115858.75cdddca.davem@redhat.com>
References: <20040308110331.GA20719@gondor.apana.org.au>
	<404C874D.4000907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <404C874D.4000907@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 08 Mar 2004 15:46:37 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Herbert Xu wrote:
> > The reason is that ip_route_me_harder which is called upon the exit
> > of the mangle table does not set the proto field.  This means that
> > xfrm_lookup is never called.
> > 
> > The following patch sets the proto field so that the packet can be
> > protected by IPsec.
> 
> I have been working on a set of patches for IPsec+Netfilter, the
> latest set has been posted to netfilter-devel last week. They will
> go in patch-o-matic for testing soon, but I will post them
> to netdev later today, so we won't waste time testing patches
> before Dave is fine with them.

Regardless, and I look forward to your work, Herbert's patch is
absolutely correct so I'm going to apply it for now.

In fact, your work is less likely to be 2.6.4 material I imagine :)
So best to get Herbert's simpler fix in for now.
