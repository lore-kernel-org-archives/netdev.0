From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Stop using dst->xfrm
Date: Tue, 25 Jan 2005 22:23:01 -0800
Message-ID: <20050125222301.5fb62202.davem@davemloft.net>
References: <20050121102319.GA3160@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050121102319.GA3160@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 21:23:19 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is a precursor to the xfrm dst consolidation that I talked about.
> In order to be able to store multiple SAs in one dst, we need to stop
> using dst->xfrm directly.
> 
> The following patch does that for the ->output() functions.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'm going to create a 2.6.12 pending queue and put this and
any forthcoming xfrm dst work there.
