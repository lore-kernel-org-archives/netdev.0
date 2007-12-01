From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] [NET] phy/fixed.c: rework to not duplicate PHY layer
 functionality
Date: Sat, 01 Dec 2007 16:59:52 -0500
Message-ID: <4751D958.6060500@garzik.org>
References: <20071126142906.19642.45540.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45683 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750938AbXLAV7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:59:54 -0500
In-Reply-To: <20071126142906.19642.45540.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaly Bordug wrote:
> With that patch fixed.c now fully emulates MDIO bus, thus no need
> to duplicate PHY layer functionality. That, in turn, drastically
> simplifies the code, and drops down line count.
> 
> As an additional bonus, now there is no need to register MDIO bus
> for each PHY, all emulated PHYs placed on the platform fixed MDIO bus.
> There is also no more need to pre-allocate PHYs via .config option,
> this is all now handled dynamically.
> 
> p.s. Don't even try to understand patch content! Better: apply patch
> and look into resulting drivers/net/phy/fixed.c.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>

what's the context of this patchset?  2.6.25?

it's late for 2.6.24-rc, IMO.

Do I have the latest version (sent Nov 26 @ 9:29am)?

	Jeff



