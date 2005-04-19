From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: remove old NET_CALLER macro
Date: Tue, 19 Apr 2005 11:35:00 -0700
Message-ID: <20050419113500.0d10c9e1.davem@davemloft.net>
References: <20050419174458.0ae804f3@localhost.localdomain>
	<E1DNnit-0001Qz-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DNnit-0001Qz-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Apr 2005 18:04:43 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Why not turn this if block into a BUG_ON? The return address will be
> printed by BUG anyway.

Also, __builtin_return_address(0) does not work reliably on some
platforms, notably MIPS.  However, you are making a straight
transformation so you're not making things any worse than before.

Eventually, this belongs in linux/compiler.h as "function_caller()"
or something like that.
