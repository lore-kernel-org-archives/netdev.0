From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Yield in netlink_broadcast when congested
Date: Tue, 19 Oct 2004 22:28:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019222807.6b1e8454.davem@davemloft.net>
References: <20041016113006.GA12843@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@eurodev.net, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041016113006.GA12843@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 16 Oct 2004 21:30:06 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> So here is my proposal: if we detect signs of impending congestion
> in netlink_broadcast(), and that we're in a sleepable context, then
> we yield().
> 
> This gives the receivers a chance to pull down the messages without
> having the sender spinning indefinitely.  I've tested it on my UP
> machine and it does resolve the problem for ip monitor.
> 
> Comments anyone?

This looks great, patch applied.

Thanks Herbert.
