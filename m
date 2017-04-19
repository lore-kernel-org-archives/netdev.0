From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] ieee802154: don't select COMMON_CLK
Date: Wed, 19 Apr 2017 22:11:45 +0200
Message-ID: <0C05AA51-5B19-416C-B708-9E0700C112E0@holtmann.org>
References: <20170419173233.3726121-1-arnd@arndb.de>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Alexander Aring <aar@pengutronix.de>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        Harry Morris <harrymorris12@gmail.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:43227 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936309AbdDSULw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 16:11:52 -0400
In-Reply-To: <20170419173233.3726121-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

> A device driver must not select the COMMON_CLK subsystem, as that conflicts
> with platforms that provide a legacy implementation of the clk API:
> 
> drivers/clk/clk.o: In function `clk_enable':
> clk.c:(.text.clk_enable+0x0): multiple definition of `clk_enable'
> arch/arm/mach-sa1100/clock.o:clock.c:(.text.clk_enable+0x0): first defined here
> drivers/clk/clk.o: In function `clk_round_rate':
> clk.c:(.text.clk_round_rate+0x0): multiple definition of `clk_round_rate'
> arch/arm/mach-sa1100/clock.o:clock.c:(.text.clk_round_rate+0x0): first defined here
> drivers/clk/clk.o: In function `clk_get_parent':
> clk.c:(.text.clk_get_parent+0x0): multiple definition of `clk_get_parent'
> arch/arm/mach-sa1100/clock.o:clock.c:(.text.clk_get_parent+0x0): first defined here
> drivers/clk/clk.o: In function `clk_get_rate':
> clk.c:(.text.clk_get_rate+0x0): multiple definition of `clk_get_rate'
> 
> This changes the 'select' into 'depends on', as all other similar drivers do.
> 
> Fixes: d931acd575d6 ("ieee802154: Add CA8210 IEEE 802.15.4 device driver")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> drivers/net/ieee802154/Kconfig | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
