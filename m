From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] Kill export of netlink_broadcast_deliver
Date: Mon, 27 Sep 2004 22:28:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927222806.17277cf3.davem@davemloft.net>
References: <20040928034736.GA10589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040928034736.GA10589@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 13:47:36 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> netlink_broadcast_deliver is marked as static as well as exported.
> It certainly isn't doing anything that should be needed by any
> netlink modules.  There aren't any in-kernel users either.
> 
> So let's remove the bogus export.

Applied, thanks Herbert.
