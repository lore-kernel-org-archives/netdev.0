From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: xilinx: axienet: use phydev from
 struct net_device
Date: Fri, 15 Jul 2016 16:43:17 -0700 (PDT)
Message-ID: <20160715.164317.1742262135870816587.davem@davemloft.net>
References: <1468518358-28735-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468518358-28735-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 14 Jul 2016 19:45:57 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
