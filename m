From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] Fix mc_list operations
Date: Mon, 15 Nov 2004 15:08:21 -0800
Message-ID: <20041115150821.50ec4647.davem@davemloft.net>
References: <20041111042136.GA17076@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041111042136.GA17076@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Nov 2004 15:21:36 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> While doing the 2.4 version of the netlink patch, I noticed a bug
> in my mc_list code.  First of all it wasn't holding the table lock
> when adding nodes to the list.  It also didn't take the node off
> the list when multicast is switched off.

Applied, thanks Herbert.
