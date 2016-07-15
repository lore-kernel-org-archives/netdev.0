From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: ll_temac: use phydev from struct
 net_device
Date: Thu, 14 Jul 2016 17:43:02 -0700 (PDT)
Message-ID: <20160714.174302.2206447776687968361.davem@davemloft.net>
References: <1468453732-7370-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	andrew@lunn.ch, f.fainelli@gmail.com, mugunthanvnm@ti.com,
	a@unstable.cc, fw@strlen.de, felipe.balbi@linux.intel.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468453732-7370-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 14 Jul 2016 01:48:51 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
