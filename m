From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPv4] Fix thinko in fib_find_alias
Date: Thu, 23 Sep 2004 13:37:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923133715.714e9c44.davem@davemloft.net>
References: <20040923041516.GA19252@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040923041516.GA19252@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2004 14:15:16 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> fib_find_alias is meant to return either an exact match or the
> entry just before where it should be.  Currently it returns the
> entry after that.  This patch fixes that.

Good fix, applied.
