From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Tue, 16 Nov 2004 16:31:06 -0800
Message-ID: <20041116163106.3b62a39a.davem@davemloft.net>
References: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
	<E1CUAQ2-0002jT-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CUAQ2-0002jT-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Nov 2004 07:59:18 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Sridhar Samudrala <sri@us.ibm.com> wrote:
> > We are seeing following assertions when running specweb99 with
> > tcp_tso_win_divisor lowered to 4, 2 or 1 on linux 2.6.9 based kernels.
> 
> 2.6.9 is known to have bugs in TCP book-keeping.  Please try 2.6.10-rc2
> instead.

Actually, that's true.  I missed that this report was against
2.6.9 vanilla, TCP is buggy as can be wrt TSO in that
release.
