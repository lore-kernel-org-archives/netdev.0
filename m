From: "David S. Miller" <davem@redhat.com>
Subject: Re: [UDP] Check encap_type at config time
Date: Fri, 25 Jun 2004 10:37:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625103751.5bf058da.davem@redhat.com>
References: <20040625121147.GA11231@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040625121147.GA11231@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 25 Jun 2004 22:11:47 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The following patch moves the udp->encap_type check from the per-packet
> hot-path into udp_setsockopt().
> 
> As a consequence, this allows user space to detect whether the kernel
> actually supports the encap type that they're requesting.  Pity no one
> did this before the NON-IKE patch was applied.  As it is there is no
> easy way to detect whether NON-IKE support is present.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, looks great.
