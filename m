From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [PATCH] Make netif_rx_ni preempt-safe
Date: Wed, 20 Oct 2004 16:25:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098303951.2268.8.camel@krustophenia.net>
References: <1098230132.23628.28.camel@krustophenia.net>
	 <200410202214.31791.vda@port.imtp.ilyichevsk.odessa.ua>
	 <1098302001.2268.5.camel@krustophenia.net>
	 <200410202256.56636.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Andrew Morton <akpm@osdl.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@gondor.apana.org.au, maxk@qualcomm.com,
        irda-users@lists.sourceforge.net,
        Linux Network Development <netdev@oss.sgi.com>,
        Alain Schroeder <alain@parkautomat.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200410202256.56636.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-10-20 at 15:56, Denis Vlasenko wrote:
> > OK, third try.
> > 
> > Signed-Off-By: Lee Revell <rlrevell@joe-job.com>
> > 
> > --- include/linux/netdevice.h~	2004-10-20 15:51:00.000000000 -0400
> > +++ include/linux/netdevice.h	2004-10-20 15:51:54.000000000 -0400
> > @@ -694,11 +694,14 @@
> >  /* Post buffer to the network code from _non interrupt_ context.
> >   * see net/core/dev.c for netif_rx description.
> >   */
> > -static inline int netif_rx_ni(struct sk_buff *skb)
> > +static int netif_rx_ni(struct sk_buff *skb)
> 
> non-inline functions must not live in .h files

Where do you suggest we put it?

Lee
