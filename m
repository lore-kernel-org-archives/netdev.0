From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] Remove netlink_sock_nr
Date: Tue, 26 Oct 2004 22:05:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026220509.2289223c.davem@davemloft.net>
References: <20041027051107.GA8784@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041027051107.GA8784@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 15:11:07 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch removes netlink_sock_nr which is only used by a printk
> statement in af_netlink.c.  Even that's only there if
> NETLINK_REFCNT_DEBUG is defined.
> 
> If we were really looking for netlink refcnt bugs there are probably
> better places to do that anyway.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
