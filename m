From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NETLINK] Return err in netlink_connect
Date: Mon, 5 Jul 2004 15:47:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705154752.2aab97b9.davem@redhat.com>
References: <20040630114144.GA31327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040630114144.GA31327@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jun 2004 21:41:44 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch makes netlink_connect() return the value of err instead of 0.
> It doesn't actually make any difference since the current implementation
> of netlink_autobind() never fails.  But since we went to all this trouble
> to check the return status of autobind, might as well return the correct
> value :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
