From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Tue, 16 Nov 2004 16:31:42 -0800
Message-ID: <20041116163142.2530566d.davem@davemloft.net>
References: <20041116104755.32bdb7a7.davem@davemloft.net>
	<E1CUA74-0002hr-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CUA74-0002hr-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Nov 2004 07:39:42 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Could you elaborate the code path that you've spotted that causes this
> when the divisor is changed?
> 
> Perhaps we're not caching the MSS value everywhere where we should be?

Currently I think your theory is better than mine, that
2.6.9 TCP is buggy wrt. TSO. :-)
