From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [1/2] [NET] Add skb_header_release and use it in net/ipv4/tcp
Date: Wed, 23 Feb 2005 19:50:09 -0800
Message-ID: <20050223195009.62e3c955.davem@davemloft.net>
References: <20050121204024.6f94fc26.davem@davemloft.net>
	<20050122054346.GA1635@gondor.apana.org.au>
	<20050122170533.GB11499@yakov.inr.ac.ru>
	<20050123071027.GA20296@gondor.apana.org.au>
	<20050126110043.GA29950@yakov.inr.ac.ru>
	<20050126222522.GA21670@gondor.apana.org.au>
	<20050127110946.GA20494@gondor.apana.org.au>
	<20050127111201.GB20494@gondor.apana.org.au>
	<20050128202542.GA23670@yakov.inr.ac.ru>
	<20050129031740.GA6130@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050129031740.GA6130@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 Jan 2005 14:17:40 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch adds skb_header_release which can be called when the owner
> of an skb no longer needs to access the header at all.  What constitutes
> the header is left up to the users of the skb to define.
> 
> For instance, for outbound TCP packets we define the header to be
> anything in front of the TCP payload.  Therefore we add skb_header_release
> calls to all the paths where outound TCP packets are produced.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Queued to 2.6.12-pending
