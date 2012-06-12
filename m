From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v10] tilegx network driver: initial support
Date: Mon, 11 Jun 2012 17:03:36 -0700 (PDT)
Message-ID: <20120611.170336.1197560839526564340.davem@davemloft.net>
References: <4FCFA312.4020505@tilera.com>
	<20120606.115440.1245419453265419850.davem@davemloft.net>
	<201206072045.q57Kj2r1009249@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201206072045.q57Kj2r1009249@farm-0002.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 7 Jun 2012 16:45:02 -0400

> This change adds support for the tilegx network driver based on the
> GXIO IORPC support in the tilegx software stack, using the on-chip
> mPIPE packet processing engine.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Applied.

Although:

> +/* The transmit wake timer for a given cpu and echannel. */
> +struct tile_net_tx_wake {
> +	struct hrtimer timer;
> +	struct net_device *dev;
> +};
> +	
   ^^^^^^^

I had to remove that trailing whitespace when I applied this.
