From: "David S. Miller" <davem@redhat.com>
Subject: Re: [AH6] Replace skb by iph in clear_mutable_options
Date: Sat, 24 Jul 2004 22:37:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724223720.6c107448.davem@redhat.com>
References: <20040724045041.GA7091@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040724045041.GA7091@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 24 Jul 2004 14:50:41 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch replaces the skb argument in ipv6_clear_mutable_options() by
> an ipv6hdr.  Doing so allows us to point skb->nh elsewhere when calling
> this function.
> 
> I've also thrown in some obvious clean-ups for that function.

Applied, thanks Herbert.

BTW, watch your patch rooting:

--- 1.33/net/ipv6/ah6.c	2004-07-24 09:54:15 +10:00
+++ edited/ah6.c	2004-07-24 14:39:24 +10:00
