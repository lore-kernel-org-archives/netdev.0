From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/4] Marvell phy: check link status in case of fiber link.
Date: Mon, 18 Jul 2016 17:32:57 +0200
Message-ID: <20160718153257.GJ19265@lunn.ch>
References: <1468832623-1792-1-git-send-email-charles-antoine.couret@nexvision.fr>
 <1468832623-1792-2-git-send-email-charles-antoine.couret@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cacouret.renault@gmail.com, netdev@vger.kernel.org
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44727 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370AbcGRPdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 11:33:00 -0400
Content-Disposition: inline
In-Reply-To: <1468832623-1792-2-git-send-email-charles-antoine.couret@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 11:03:40AM +0200, Charles-Antoine Couret wrote:

Hi Charles-Antoine

Looking good. Just one nitpick.

>  /* marvell_read_status

You missed changing this name above.

>   *
> - * Generic status code does not detect Fiber correctly!
>   * Description:
>   *   Check the link, then figure out the current state
>   *   by comparing what we advertise with what the link partner
>   *   advertises.  Start by checking the gigabit possibilities,
>   *   then move on to 10/100.
>   */
> -static int marvell_read_status(struct phy_device *phydev)
> +static int marvell_read_status_page(struct phy_device *phydev, int page)

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
