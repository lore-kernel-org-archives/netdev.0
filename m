From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [12/*] [IPSEC] Handle local_df in IPv4
Date: Mon, 14 Mar 2005 21:25:57 -0800
Message-ID: <20050314212557.23f0ab09.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050314102614.GA9610@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 21:26:14 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> When cleaning up the remaining users of dst_pmtu I noticed that
> local_df wasn't being treated correctly in IPsec.  In fact, if
> you socket's dst went over IPsec, local_df is essentailly ignored.
> 
> This patch fixes that.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

> I was going to do the same thing to IPv6.  Unfortunately it seems
> that we don't have any local_df support over there.  That is, we
> always fragment outbound UDP/raw packets.  Did I miss something?

I have no idea offhand.  Perhaps Yoshifuji can figure it out?
