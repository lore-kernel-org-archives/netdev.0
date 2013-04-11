From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 10:35:25 -0700
Message-ID: <1365701725.3887.177.camel@edumazet-glaptop>
References: <CABJ1b_TQDabT1J7ffo5cb1Th=71bcSduifMJaDpfVRiiHvtWDw@mail.gmail.com>
	 <20130411150326.GA19978@1wt.eu>
	 <CABJ1b_TRxm97DKJLP_h0VwMJvcYmSpjoJvtg1KvBNGah=VzqMQ@mail.gmail.com>
	 <20130411.133119.913809939413807690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, w@1wt.eu, andrew@lunn.ch,
	jason@lakedaemon.net, benh@kernel.crashing.org,
	linux-kernel@vger.kernel.org, florian@openwrt.org, smoch@web.de,
	paulus@samba.org, buytenh@wantstofly.org, dale@farnsworth.org,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130411.133119.913809939413807690.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-11 at 13:31 -0400, David Miller wrote:

> I think, as per other drivers, LRO should be eliminated completely from
> all drivers, including this one, and GRO used exclusively instead.

This would be awesome.

AFAIK current LRO users are :

drivers/infiniband/hw/nes/nes_hw.c
drivers/net/ethernet/marvell/mv643xx_eth.c
drivers/net/ethernet/pasemi/pasemi_mac.c
