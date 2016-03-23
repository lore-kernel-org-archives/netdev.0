From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] led: at8030: Add LED driver for AT8030 ethernet PHY
Date: Wed, 23 Mar 2016 19:52:46 +0100
Message-ID: <20160323185246.GM5250@lunn.ch>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
 <1458755500-15571-4-git-send-email-vishalthanki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, ujhelyi.m@gmail.com, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55640 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206AbcCWSwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 14:52:47 -0400
Content-Disposition: inline
In-Reply-To: <1458755500-15571-4-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void at803x_led_work(struct work_struct *work)
> +{
> +	struct at803x_phy_led *led =
> +		container_of(work, struct at803x_phy_led, work);
> +	union at803x_led_manual_ctrl regval = led->regval;
> +
> +	phy_write(led->led_grp->phydev, led->reg, regval.value);
> +}
> +

There has recently been a big refactoring of the LED code. You should
no longer need a work queue. The core will do that for you.

   Andrew
