From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC]: Protect against BHs in xfrm_user_policy()
Date: Mon, 4 Apr 2005 10:35:09 -0700
Message-ID: <20050404103509.06ca48a4.davem@davemloft.net>
References: <4250160D.2040405@trash.net>
	<20050404012040.GA16960@gondor.apana.org.au>
	<20050404115508.GA12171@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404115508.GA12171@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Apr 2005 21:55:08 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The read_lock()'s only need to be protected from the write_lock()'s.
> 
> Since all the write_lock()'s are made in process context, we don't
> need to disable BH on the read_lock()'s.

This is correct.

It's actually a common technique, only disable IRQ or BH in
the write_locks.
