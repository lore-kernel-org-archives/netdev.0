From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4] Clear DF bit in ip_fragment fast path
Date: Wed, 23 Mar 2005 12:20:54 -0800
Message-ID: <20050323122054.4603c3c9.davem@davemloft.net>
References: <20050321105622.GA23809@gondor.apana.org.au>
	<20050321111637.GA24617@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050321111637.GA24617@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 22:16:37 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> It is possible for ip_fragment() to send out head fragments with
> both DF and MF set for packets with local_df set to true.  This is
> because the fast path tries to only modify the MF bit of the head
> fragment.
> 
> Since the offset is always zero for the head fragment, and we know
> that DF should be cleared in case of local_df, we can change |= to
> a straight assignment.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks Herbert.
