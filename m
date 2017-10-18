From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: master and slave helpers
Date: Wed, 18 Oct 2017 12:24:53 +0100 (WEST)
Message-ID: <20171018.122453.2063474159565652979.davem@davemloft.net>
References: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 16 Oct 2017 11:12:12 -0400

> This patch series adds a few helpers to DSA core for clarity and
> readability but brings no functional changes.
> 
> A dsa_slave_notify helper calls the DSA notifiers when (un)registering a
> slave device.
> 
> Most of the DSA slave code only needs to access the dsa_port structure,
> not the dsa_slave_priv (which only contains a few PHY-specific members).
> Thus a dsa_slave_to_port helper returns a dsa_port structure of a slave
> device.
> 
> A dsa_slave_to_master returns the master device of a slave device.
> 
> After that the netdev member of the dsa_port structure is split into two
> explicit master and slave members to avoid confusion, and a dsa_to_port
> helper is added for switch drivers to get a const reference to a port.
> 
> Changes in v2:
>   - prefer dsa_slave_to_master instead of dsa_slave_get_master
>   - rename dsa_master_get_slave to dsa_master_find_slave
>   - pack master and slave net devices into an anonymous union
>   - add dsa_to_port public helper for switch drivers
>   - add Reviewed-by tags from Florian

Series applied.
