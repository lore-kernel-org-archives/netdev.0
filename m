From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Revert pskb change for x->type->output
Date: Fri, 20 Aug 2004 14:09:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040820140920.48834389.davem@redhat.com>
References: <20040820082331.GA23626@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040820082331.GA23626@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Aug 2004 18:23:31 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Since skb_checksum_help() has been moved to xfrm[46]_output(), we don't
> need the sk_buff ** argument in x->type->output anymore.  This patch
> reverts it to a sk_buff *.

Works for me, applied.
