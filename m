From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 5/5] net: mdio-mux: fix unbalanced put_device
Date: Fri, 1 Sep 2017 15:38:50 +0200
Message-ID: <20170901133850.GA22289@lunn.ch>
References: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
 <20170901115604.27513-6-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170901115604.27513-6-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2017 at 01:56:04PM +0200, Corentin Labbe wrote:
> mdio_mux_uninit() call put_device (unconditionally) because of
> of_mdio_find_bus() in mdio_mux_init.
> But of_mdio_find_bus is only called if mux_bus is empty.
> If mux_bus is set, mdio_mux_uninit will print a "refcount_t: underflow"
> trace.
> 
> This patch add a get_device in the other branch of "if (mux_bus)".
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
