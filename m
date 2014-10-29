From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: Fix gpios for device tree based booting
Date: Wed, 29 Oct 2014 14:51:32 -0400 (EDT)
Message-ID: <20141029.145132.1881832564707108447.davem@davemloft.net>
References: <20141027202556.GT2560@atomide.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-omap@vger.kernel.org, khilman@linaro.org
To: tony@atomide.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20141027202556.GT2560@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tony Lindgren <tony@atomide.com>
Date: Mon, 27 Oct 2014 13:25:56 -0700

> +/**
> + * of_try_set_control_gpio - configure a gpio if it exists
> + */
> +static int try_toggle_control_gpio(struct device *dev,
> +				   struct gpio_desc **desc,
> +				   const char *name, int index,
> +				   int value, unsigned int nsdelay)

This needs to be under CONFIG_OF cpp protection just like the code that
calls it.
