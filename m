From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9-rc4 tcp_transmit_skb: BUG_ON(!tcp_skb_pcount(skb))
Date: Tue, 19 Oct 2004 22:13:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019221301.1490c1f6.davem@davemloft.net>
References: <20041013231006.GA14742@m.safari.iki.fi>
	<E1CILsE-0005cJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 7atbggg02@sneakemail.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CILsE-0005cJ-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Oct 2004 16:47:34 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Sami Farin <7atbggg02@sneakemail.com> wrote:
> > 
> > tcp_output.c:277
> > Invalid operand 0
> > tcp_transmit_skb
> > tcp_send_synack
> > tcp_rcv_synsent_state_process
> 
> OK, this patch should fix it.
> 
> We weren't copying the TSO fields in skb_copy().
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Great catch Herbert.  Patch applied, thanks.
