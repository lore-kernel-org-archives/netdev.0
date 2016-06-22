From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: bgmac: use phydev from struct
 net_device
Date: Wed, 22 Jun 2016 16:26:19 -0400 (EDT)
Message-ID: <20160622.162619.1775999677396362968.davem@davemloft.net>
References: <1466368626-28985-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, zajec5@gmail.com,
	fabio.estevam@freescale.com, jkosina@suse.cz, andrew@lunn.ch,
	nbd@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466368626-28985-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 19 Jun 2016 22:37:05 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
