From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] xfrm_alloc_spi always succeeds on non-trivial range
Date: Sat, 31 Jul 2004 23:45:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731234513.744d4793.davem@redhat.com>
References: <20040731020044.GA13830@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040731020044.GA13830@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 31 Jul 2004 12:00:44 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> xfrm_alloc_spi will always succeed if minspi < maxspi, even if
> minspi + 1 == maxspi.  If the range is already occupied this
> will obviously lead to breakage.
> 
> Of course this is very unlikely to occur in reality due to the
> size of the range.  Although with IPCOMP it might actually happen
> on a very large server.
> 
> The fix is obivous.

Indeed, applied.

You're certainly making the rounds auditing the SPI handling lately.
:-)  It is much appreciated.
