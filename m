From: Sami Farin <7atbggg02@sneakemail.com>
Subject: Re: 2.6.9-rc4 tcp_transmit_skb: BUG_ON(!tcp_skb_pcount(skb))
Date: Fri, 15 Oct 2004 11:47:07 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015084707.GA29106@m.safari.iki.fi>
References: <20041013231006.GA14742@m.safari.iki.fi> <E1CILsE-0005cJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <E1CILsE-0005cJ-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 15, 2004 at 04:47:34PM +1000, Herbert Xu wrote:
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
> 
> Cheers,

Thank you!  I can't reproduce the BUG anymore.
Hopefully this fix gets into 2.6.9-final.

-- 
