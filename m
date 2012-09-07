From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/phy: mdio-mux-mmioreg.c should include
 of_address.h
Date: Fri, 07 Sep 2012 17:25:06 -0400 (EDT)
Message-ID: <20120907.172506.1680438781148301994.davem@davemloft.net>
References: <1347048592-22957-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, sfr@canb.auug.org.au,
	rdunlap@xenotime.net
To: timur@freescale.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1347048592-22957-1-git-send-email-timur@freescale.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Timur Tabi <timur@freescale.com>
Date: Fri, 7 Sep 2012 15:09:52 -0500

> mdio-mux-mmioreg.c uses function of_address_to_resource(), which is defined
> in linux/of_address.h.  This fixes a compilation error:
> 
> drivers/net/phy/mdio-mux-mmioreg.c: In function 'mdio_mux_mmioreg_probe':
> drivers/net/phy/mdio-mux-mmioreg.c:83:2: error: implicit declaration of
> 	function 'of_address_to_resource'
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Please provide "Reported-by: ..." tags to give credit to the problem
reporter, Randy Dunlap in this case.
