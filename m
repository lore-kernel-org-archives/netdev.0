From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2] net: mvneta: set rx mode during resume if
 interface is running
Date: Wed, 29 Mar 2017 14:57:48 +0200
Message-ID: <20170329125748.GD28922@lunn.ch>
References: <20170329084719.3596-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni@free-electrons.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329084719.3596-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 04:47:19PM +0800, Jisheng Zhang wrote:
> I found a bug by:
> 
> 0. boot and start dhcp client
> 1. echo mem > /sys/power/state
> 2. resume back immediately
> 3. don't touch dhcp client to renew the lease
> 4. ping the gateway. No acks
> 
> Usually, after step2, the DHCP lease isn't expired, so in theory we
> should resume all back. But in fact, it doesn't. It turns out
> the rx mode isn't resumed correctly. This patch fixes it by adding
> mvneta_set_rx_mode(dev) in the resume hook if interface is running.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
