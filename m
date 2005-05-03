From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV6] Fix raw socket checksums with IPsec
Date: Tue, 3 May 2005 14:23:55 -0700
Message-ID: <20050503142355.7f2c7ba5.davem@davemloft.net>
References: <20050430123301.GA25174@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, dlstevens@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050430123301.GA25174@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Apr 2005 22:33:01 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I made a mistake in my last patch to the raw socket checksum code.
> I used the value of inet->cork.length as the length of the payload.
> While this works with normal packets, it breaks down when IPsec is
> present since the cork length includes the extension header length.
> 
> So here is a patch to fix the length calculations.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
