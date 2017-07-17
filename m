From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Mon, 17 Jul 2017 23:21:37 +0200
Message-ID: <20170717212137.GD11719@lunn.ch>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com, netdev@vger.kernel.org,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58377 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751987AbdGQVVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 17:21:42 -0400
Content-Disposition: inline
In-Reply-To: <1500325749-8382-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 17, 2017 at 06:09:09PM -0300, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> The gpiod API checks for NULL descriptors, so there is no need to
> duplicate the check in the driver.
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

VALIDATE_DESC is ugly. But:

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
