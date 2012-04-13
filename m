From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net: Remove redundant spi driver bus initialization
Date: Fri, 13 Apr 2012 13:13:51 -0400 (EDT)
Message-ID: <20120413.131351.1360677415220330018.davem@davemloft.net>
References: <1334091089-10138-1-git-send-email-lars@metafoo.de>
	<1334091089-10138-4-git-send-email-lars@metafoo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, juhosg@openwrt.org,
	frdrc66@gmail.com, netdev@vger.kernel.org
To: lars@metafoo.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334091089-10138-4-git-send-email-lars@metafoo.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars-Peter Clausen <lars@metafoo.de>
Date: Tue, 10 Apr 2012 22:51:29 +0200

> In ancient times it was necessary to manually initialize the bus field of an
> spi_driver to spi_bus_type. These days this is done in spi_driver_register() so
> we can drop the manual assignment.
> 
> The patch was generated using the following coccinelle semantic patch:
> // <smpl>
> @@
> identifier _driver;
> @@
> struct spi_driver _driver = {
> 	.driver = {
> -		.bus = &spi_bus_type,
> 	},
> };
> // </smpl>
> 
> Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>

Applied to net-next, thanks.
