From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: gianfar: use phydev from struct
 net_device
Date: Mon, 16 May 2016 21:51:52 -0400 (EDT)
Message-ID: <20160516.215152.1285555270034702683.davem@davemloft.net>
References: <1463355009-19803-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463355009-19803-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 16 May 2016 01:30:08 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
