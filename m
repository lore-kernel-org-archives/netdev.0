From: "David S. Miller" <davem@redhat.com>
Subject: Re: [AH6] Disallow mutable bits after AH header
Date: Fri, 23 Jul 2004 13:37:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723133737.447a9598.davem@redhat.com>
References: <20040723135320.GA26000@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040723135320.GA26000@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Jul 2004 23:53:21 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> As we discussed before, mutable headers should not be allowed after
> the AH header.  In fact, this appears to be the intention of RFC 2402.
> It is further clarified in section 3.1.1 of
> 
> http://www.ietf.org/internet-drafts/draft-ietf-ipsec-rfc2402bis-07.txt
> 
> This allows us to simplify the code in ah6.c.  As a result, this also
> fixes the following issues:
> 
> * Dependence on skb->h in ah6_output().
> * Bogus clearing of auth_data of 2nd AH header in ipv6_clear_mutable_options().

Applied, thanks Herbert.
