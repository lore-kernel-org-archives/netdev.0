From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [TCP] Modular IPv6 support in tcpdiag
Date: Wed, 3 Nov 2004 09:16:09 -0800
Message-ID: <20041103091609.7f6d5d9c@zqx3.pdx.osdl.net>
References: <20041103094451.GA20220@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041103094451.GA20220@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Nov 2004 20:44:51 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Dave:
> 
> This patch allows tcpdiag to support ipv6 work as a module when itself
> is also a module.
> 
> I was planning for a more extensible method but now I think the effort
> would be better directed at a new generic socket netlink interface than
> the TCP-specific tcpdiag.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I wanted to ask why all the work to make tcp_diag a module? If it is
a module there are more possibilties of user problems. Any utilities
that expect it would then have to deal with it not being loaded as well
as the possiblity of building a kernel without it.

Perhaps there ought to be a CONFIG_INET_EMBEDDED that is for those
configurations that want more restricted and smaller networking (ie no
cache's, smaller hash tables, less sysctl options, ...)
