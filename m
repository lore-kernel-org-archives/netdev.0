From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v2] netdev/phy: mdio-mux-mmioreg.c should include
 of_address.h
Date: Fri, 07 Sep 2012 17:32:57 -0400 (EDT)
Message-ID: <20120907.173257.685485936431214053.davem@davemloft.net>
References: <1347053457-24935-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, sfr@canb.auug.org.au,
	rdunlap@xenotime.net
To: timur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347053457-24935-1-git-send-email-timur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Timur Tabi <timur@freescale.com>
Date: Fri, 7 Sep 2012 16:30:57 -0500

> mdio-mux-mmioreg.c uses function of_address_to_resource(), which is defined
> in linux/of_address.h.  This fixes a compilation error:
> 
> drivers/net/phy/mdio-mux-mmioreg.c: In function 'mdio_mux_mmioreg_probe':
> drivers/net/phy/mdio-mux-mmioreg.c:83:2: error: implicit declaration of
> 	function 'of_address_to_resource'
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied, thanks.
