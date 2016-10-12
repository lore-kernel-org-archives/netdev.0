From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: mv643xx_eth: use phydev from struct net_device
Date: Wed, 12 Oct 2016 01:40:56 -0400 (EDT)
Message-ID: <20161012.014056.252399120931987245.davem@davemloft.net>
References: <1475402809-11593-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475402809-11593-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  2 Oct 2016 12:06:48 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
