From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [PATCH] Make netif_rx_ni preempt-safe
Date: Wed, 20 Oct 2004 23:32:33 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410202332.33583.vda@port.imtp.ilyichevsk.odessa.ua>
References: <1098230132.23628.28.camel@krustophenia.net> <200410202256.56636.vda@port.imtp.ilyichevsk.odessa.ua> <1098303951.2268.8.camel@krustophenia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Andrew Morton <akpm@osdl.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@gondor.apana.org.au, maxk@qualcomm.com,
        irda-users@lists.sourceforge.net,
        Linux Network Development <netdev@oss.sgi.com>,
        Alain Schroeder <alain@parkautomat.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <1098303951.2268.8.camel@krustophenia.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 20 October 2004 23:25, Lee Revell wrote:
> > > --- include/linux/netdevice.h~	2004-10-20 15:51:00.000000000 -0400
> > > +++ include/linux/netdevice.h	2004-10-20 15:51:54.000000000 -0400
> > > @@ -694,11 +694,14 @@
> > >  /* Post buffer to the network code from _non interrupt_ context.
> > >   * see net/core/dev.c for netif_rx description.
> > >   */
> > > -static inline int netif_rx_ni(struct sk_buff *skb)
> > > +static int netif_rx_ni(struct sk_buff *skb)
> > 
> > non-inline functions must not live in .h files
> 
> Where do you suggest we put it?

Somewhere near this place:

http://lxr.linux.no/source/net/core/dev.c?v=2.6.8.1#L1555
--
vda
