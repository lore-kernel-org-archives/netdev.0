From: James Morris <jmorris@redhat.com>
Subject: Re: RFC: pskb_expand_head instead of skb_copy in skb_checksum_help
Date: Tue, 24 Aug 2004 16:53:16 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0408241652320.21615-100000@thoron.boston.redhat.com>
References: <20040824115541.52955b2a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040824115541.52955b2a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004, David S. Miller wrote:

> On Tue, 24 Aug 2004 21:05:32 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > The idea is simple.  None of the callers of skb_checksum are passing it
> > skb's which are shared.  They may be cloned however.  But the application
> > checksum is always in the skb header so there is no need to linearise it.
> 
> What about looping back of multicast packets via netif_rx(),
> is that handled correctly too?

They are clones.  I can easily regression test it if needed.


- James
-- 
James Morris
<jmorris@redhat.com>
