From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: pskb_expand_head instead of skb_copy in skb_checksum_help
Date: Tue, 24 Aug 2004 11:55:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824115541.52955b2a.davem@redhat.com>
References: <20040824110532.GA10241@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040824110532.GA10241@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 21:05:32 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The idea is simple.  None of the callers of skb_checksum are passing it
> skb's which are shared.  They may be cloned however.  But the application
> checksum is always in the skb header so there is no need to linearise it.

What about looping back of multicast packets via netif_rx(),
is that handled correctly too?

I only mention it because that is the case that causes
problems elsewhere.

I'm going to think over this later today some more.
