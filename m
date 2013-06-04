From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH] net: sun4i-emac: remove erroneous assignment
Date: Tue, 4 Jun 2013 15:40:34 +0200
Message-ID: <20130604134034.GE3283@lukather>
References: <3298610.K0DeJZEM4E@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Roese <sr@denx.de>,
	Richard Genoud <richard.genoud@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:57660 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337Ab3FDNkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 09:40:37 -0400
Content-Disposition: inline
In-Reply-To: <3298610.K0DeJZEM4E@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On Mon, Jun 03, 2013 at 11:36:50PM +0200, Arnd Bergmann wrote:
> The newly added sun4i-emac driver causes a build error when
> CONFIG_NET_POLL_CONTROLLER is set, because it attempts to
> assign a pointer to netdev->poll_controller, which has
> been replaced with ops->ndo_poll_controller in 2.6.31!
> 
> The correct assignment is present as well, so we just need
> to remove the wrong one.

Thanks for fixing this,
Acked-by: Maxime Ripard <maxime.ripard@anandra.org>

Maxime
