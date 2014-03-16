From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V2 RE-SEND 1/7] net: sxgbe: add basic framework for
 Samsung 10Gb ethernet driver
Date: Mon, 17 Mar 2014 00:11:01 +0100
Message-ID: <20140316231101.GA23765@electric-eye.fr.zoreil.com>
References: <007a01cf3e89$3bbdf460$b339dd20$%an@samsung.com>
 <20140314004454.GA10982@electric-eye.fr.zoreil.com>
 <000e01cf40ac$08c19290$1a44b7b0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	davem@davemloft.net, ilho215.lee@samsung.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, "'Joe Perches'" <joe@perches.com>
To: "Andrew.an" <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <000e01cf40ac$08c19290$1a44b7b0$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew.an <bh74.an@samsung.com> :
[...]
> > > +struct sxgbe_core_ops {
> > > +	/* MAC core initialization */
> > > +	void (*core_init)(void __iomem *ioaddr);
[...]
> > > +	/* adjust SXGBE speed */
> > > +	void (*set_speed)(void __iomem *ioaddr, unsigned char speed);
> > > +};
> > 
> > This indirection level is never used.
> Those are used, can you give more detail?

They are used but they always point to the same set of methods.
Those methods could thus be directly called.

[...]
> > > +/* SXGBE private data structures */
> > > +struct sxgbe_tx_queue {
> > > +	u8 queue_no;
> > > +	unsigned int irq_no;
> > > +	struct sxgbe_priv_data *priv_ptr;
> > > +	struct sxgbe_tx_norm_desc *dma_tx;
> > 
> > You may lay things a bit differently.
> can you give more detail?

Bigger fields first, u8 at the end. It will save padding in the struct.

-- 
Ueimor
