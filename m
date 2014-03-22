From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V11 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Sat, 22 Mar 2014 15:23:41 -0700
Message-ID: <008901cf461d$63cbf2e0$2b63d8a0$@samsung.com>
References: <007f01cf4597$50abac40$f20304c0$@samsung.com>
 <CAOwfj2O=c7YmcxwCLb1EDsu5j=PG7C_5LTrqrcSkpaTOQp-_Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>,
	'Jay Bhat' <j.bhat@samsung.com>
To: 'Vince Bridgers' <vbridgers2013@gmail.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <CAOwfj2O=c7YmcxwCLb1EDsu5j=PG7C_5LTrqrcSkpaTOQp-_Yg@mail.gmail.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Vince Bridgers <vbridgers2013@gmail.com> :
> On Sat, Mar 22, 2014 at 1:23 AM, Byungho An <bh74.an@samsung.com> wrote:
> > From: Siva Reddy <siva.kallam@samsung.com>
> >
> > This patch adds support for Samsung 10Gb ethernet driver(sxgbe).
> >

[snip]

> > +static int sxgbe_init_rx_buffers(struct net_device *dev,
> > +                                struct sxgbe_rx_norm_desc *p, int i,
> > +                                unsigned int dma_buf_sz,
> > +                                struct sxgbe_rx_queue *rx_ring)
> > +{
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +       struct sk_buff *skb;
> > +
> > +       skb = __netdev_alloc_skb(dev, dma_buf_sz, GFP_KERNEL);
> > +       if (!skb)
> > +               return -ENOMEM;
> > +
> > +       skb_reserve(skb, NET_IP_ALIGN);
> 
> Considering using netdev_alloc_skb_ip_align here as well. Looks like
> it was changed in refill, but not here
OK. Thanks

> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
