From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] at91_ether: use gpio_is_valid for phy IRQ line
Date: Tue, 29 Nov 2011 18:53:42 -0500 (EST)
Message-ID: <20111129.185342.105454076866922618.davem@davemloft.net>
References: <1322128098-17724-1-git-send-email-jamie@jamieiles.com>
	<1322169674-4109-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamie@jamieiles.com, netdev@vger.kernel.org, plagnioj@jcrosoft.com,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: nicolas.ferre@atmel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1322169674-4109-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Thu, 24 Nov 2011 22:21:14 +0100

> Use the generic gpiolib gpio_is_valid() function to test
> if the phy IRQ line GPIO is actually provided.
> 
> For non-connected or non-existing phy IRQ lines, -EINVAL
> value is used for phy_irq_pin field of struct at91_eth_data.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

I'm assuming this goes through the ARM tree, because in both of my networking
trees there is no ARM at91 implementation of gpio_is_valid().
