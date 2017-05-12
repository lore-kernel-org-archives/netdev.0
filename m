From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mdio: mux: fix device_node_continue.cocci warnings
Date: Fri, 12 May 2017 12:22:23 -0400 (EDT)
Message-ID: <20170512.122223.341607427763777325.davem@davemloft.net>
References: <alpine.DEB.2.20.1705122252440.3416@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.mason@broadcom.com, andrew@lunn.ch,
        f.fainelli@gmail.com, kbuild-all@01.org,
        linux-kernel@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1705122252440.3416@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Fri, 12 May 2017 22:54:23 +0800 (SGT)

> Device node iterators put the previous value of the index variable, so an
> explicit put causes a double put.
 ...
> @@ -169,7 +169,6 @@ int mdio_mux_init(struct device *dev,
>  		if (r) {
>  			mdiobus_free(cb->mii_bus);
>  			devm_kfree(dev, cb);
> -			of_node_put(child_bus_node);
>  		} else {

I think we're instead simply missing a break; statement here.
