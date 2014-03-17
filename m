From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V3 2/8] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Mon, 17 Mar 2014 14:58:05 -0700
Message-ID: <00c501cf422b$faf26410$f0d72c30$@samsung.com>
References: <00bf01cf4221$95373150$bfa593f0$@samsung.com>
 <20140317.171825.1118518563919818497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, ilho215.lee@samsung.com
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <20140317.171825.1118518563919818497.davem@davemloft.net>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller <davem@davemloft.net> :
> From: Byungho An <bh74.an@samsung.com>
> Date: Mon, 17 Mar 2014 13:43:37 -0700
> 
> > +static void sxgbe_tx_timer(unsigned long data) {
> > +	struct sxgbe_tx_queue *p = (struct sxgbe_tx_queue *)data;
> > +	sxgbe_tx_queue_clean(p);
> > +}
> 
> A empty line after local variable declarations please.
> 
> > +	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
> > +		struct sxgbe_tx_queue *p = priv->txq[queue_num];
> > +		p->tx_coal_frames =  SXGBE_TX_FRAMES;
> 
> Likewise.
> 
> > +	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
> > +		struct sxgbe_tx_queue *p = priv->txq[queue_num];
> > +		del_timer_sync(&p->txtimer);
> > +	}
> 
> Likewise.
> 
> Please audit your entire submission for this problem.
OK, will do that.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of
> a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
