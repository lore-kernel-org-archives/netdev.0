From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: altera_tse: use phydev from struct
 net_device
Date: Wed, 22 Jun 2016 16:26:02 -0400 (EDT)
Message-ID: <20160622.162602.223286576700913883.davem@davemloft.net>
References: <1466260641-22506-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466260641-22506-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 18 Jun 2016 16:37:20 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
