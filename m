From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: at803x: Add support to control PHY LEDs
Date: Thu, 17 Mar 2016 15:50:32 +0100
Message-ID: <20160317145032.GB26019@lunn.ch>
References: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
 <1458223147-16142-2-git-send-email-vishalthanki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ujhelyi.m@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49369 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302AbcCQOue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 10:50:34 -0400
Content-Disposition: inline
In-Reply-To: <1458223147-16142-2-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 02:59:07PM +0100, Vishal Thanki wrote:
> The LEDs can be turned on and off by a sysfs interface
> now. Write 0 to "led_enable" file to turn off the LEDs
> and write 1 to turn on. The support is experimental
> and can be enabled by kernel configuration option.
> 
> Signed-off-by: Vishal Thanki <vishalthanki@gmail.com>
> ---
>  drivers/net/phy/Kconfig  |  7 +++++
>  drivers/net/phy/at803x.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++

Hi Vishal

This solution seems specific to the at803. You should be thinking of a
generic solution that all PHYs can use. eg add a new callback function
to phy_driver, and put the sysfs handling code in phylib.

   Andrew
