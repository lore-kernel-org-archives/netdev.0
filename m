From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Merge xfrm4_bundle_ok/xfrm6_bundle_ok/stale_bundle
Date: Tue, 15 Feb 2005 14:17:43 -0800
Message-ID: <20050215141743.1010f2e6.davem@davemloft.net>
References: <20050129123803.GA17390@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050129123803.GA17390@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 Jan 2005 23:38:03 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch merges __xfrm4_bundle_ok/__xfrm6_bundle_ok/stale_bundle
> so that when I add MTU verification code I don't have to put it in
> three places.
> 
> It also moves the tests on dst->dev and dst->obsolete outside the
> loop since the former is identical throughout the bundle and the
> latter can only be positive on the final element which also happens
> to be dst->path.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to my 2.6.12-pending tree.  Thanks a lot.
