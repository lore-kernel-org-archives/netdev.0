From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 5/5] net: mdio-mux: fix unbalanced put_device
Date: Wed, 30 Aug 2017 20:53:46 +0200
Message-ID: <20170830185346.GJ22289@lunn.ch>
References: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
 <20170830174651.30325-6-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170830174651.30325-6-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  err_pb_kz:
>  	/* balance the reference of_mdio_find_bus() took */

Hi Corentin

This comment should probably be updated as well. 

> -	if (!mux_bus)
> -		put_device(&parent_bus->dev);
> +	put_device(&parent_bus->dev);

  Thanks
     Andrew
