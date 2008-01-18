From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/3] [NET] phy/fixed.c: rework to not duplicate PHY layer
 functionality
Date: Fri, 18 Jan 2008 00:45:40 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0801180045230.16260@blarg.am.freescale.net>
References: <20071206225121.31080.86606.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47283 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809AbYARGsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 01:48:05 -0500
In-Reply-To: <20071206225121.31080.86606.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Dec 2007, Vitaly Bordug wrote:

>
> With that patch fixed.c now fully emulates MDIO bus, thus no need
> to duplicate PHY layer functionality. That, in turn, drastically
> simplifies the code, and drops down line count.
>
> As an additional bonus, now there is no need to register MDIO bus
> for each PHY, all emulated PHYs placed on the platform fixed MDIO bus.
> There is also no more need to pre-allocate PHYs via .config option,
> this is all now handled dynamically.
>
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> Acked-by: Jeff Garzik <jeff@garzik.org>
>
> ---
>
>  drivers/net/phy/Kconfig   |   32 +--
>  drivers/net/phy/fixed.c   |  445 +++++++++++++++++----------------------------
>  include/linux/phy_fixed.h |   51 ++---
>  3 files changed, 195 insertions(+), 333 deletions(-)
>

applied.

- k
