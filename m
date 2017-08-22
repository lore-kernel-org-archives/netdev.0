From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] fsl/man: Inherit parent device and of_node
Date: Tue, 22 Aug 2017 16:32:49 -0700 (PDT)
Message-ID: <20170822.163249.2209959212952243626.davem@davemloft.net>
References: <20170822222447.16754-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, junote@outlook.com, madalin.bucur@nxp.com,
        linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170822222447.16754-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 22 Aug 2017 15:24:47 -0700

> Junote Cai reported that he was not able to get a DSA setup involving the
> Freescale DPAA/FMAN driver to work and narrowed it down to
> of_find_net_device_by_node(). This function requires the network device's
> device reference to be correctly set which is the case here, though we have
> lost any device_node association there.
> 
> The problem is that dpaa_eth_add_device() allocates a "dpaa-ethernet" platform
> device, and later on dpaa_eth_probe() is called but SET_NETDEV_DEV() won't be
> propagating &pdev->dev.of_node properly. Fix this by inherenting both the parent
> device and the of_node when dpaa_eth_add_device() creates the platform device.
> 
> Fixes: 3933961682a3 ("fsl/fman: Add FMan MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
