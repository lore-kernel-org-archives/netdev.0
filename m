From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP] Modular IPv6 support in tcpdiag
Date: Wed, 3 Nov 2004 12:20:50 -0800
Message-ID: <20041103122050.50f6f556.davem@davemloft.net>
References: <20041103094451.GA20220@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041103094451.GA20220@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Nov 2004 20:44:51 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch allows tcpdiag to support ipv6 work as a module when itself
> is also a module.

Any particular reason you didn't use the same config ifdef
tests we use for structure layouts?  Ie.

#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

I don't see the need for the special new config option.
