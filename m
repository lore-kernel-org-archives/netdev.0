From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] at91_ether: use gpio_is_valid for phy IRQ line
Date: Wed, 30 Nov 2011 05:44:03 +0100
Message-ID: <20111130044403.GY15008@game.jcrosoft.org>
References: <1322128098-17724-1-git-send-email-jamie@jamieiles.com>
 <1322169674-4109-1-git-send-email-nicolas.ferre@atmel.com>
 <20111129.185342.105454076866922618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.ferre@atmel.com, jamie@jamieiles.com,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111129.185342.105454076866922618.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18:53 Tue 29 Nov     , David Miller wrote:
> From: Nicolas Ferre <nicolas.ferre@atmel.com>
> Date: Thu, 24 Nov 2011 22:21:14 +0100
> 
> > Use the generic gpiolib gpio_is_valid() function to test
> > if the phy IRQ line GPIO is actually provided.
> > 
> > For non-connected or non-existing phy IRQ lines, -EINVAL
> > value is used for phy_irq_pin field of struct at91_eth_data.
> > 
> > Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> I'm assuming this goes through the ARM tree, because in both of my networking
> trees there is no ARM at91 implementation of gpio_is_valid().
yes the depending patch series is in the arm-soc

can we have your ack or sob?

Best Regards,
J.
