From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] bgmac: make bgmac depend on bcm47xx
Date: Wed, 24 Jul 2013 09:54:12 -0400
Message-ID: <20130724135409.GA2385@tuxdriver.com>
References: <1374614929-7528-1-git-send-email-hauke@hauke-m.de>
 <20130724110858.01e033323d739cf6b998e2ea@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hauke Mehrtens <hauke@hauke-m.de>, davem@davemloft.net,
	zajec5@gmail.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50393 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab3GXOAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 10:00:13 -0400
Content-Disposition: inline
In-Reply-To: <20130724110858.01e033323d739cf6b998e2ea@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 24, 2013 at 11:08:58AM +1000, Stephen Rothwell wrote:
> Hi,
> 
> On Tue, 23 Jul 2013 23:28:49 +0200 Hauke Mehrtens <hauke@hauke-m.de> wrote:
> >
> > bgmac uses bcm47xx_nvram.h which is only available when BCM47XX was
> > selected. Earlier BCMA_HOST_SOC depended on BCM47XX so this was not
> > build on any other archs, but that changed. We should modify this
> > driver to get access to the nvram or the variables through platform
> > data.
> > 
> > This fixes a build problem in linux-next reported by Stephen Rothwell:
> > 
> > drivers/net/ethernet/broadcom/bgmac.c:19:27: fatal error: bcm47xx_nvram.h: No such file or directory
> >  #include <bcm47xx_nvram.h>
> >                            ^
> > 
> > Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> > Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> 
> This patch really needs to go to John as the patch that exposes the
> breakage is in his tree.

I'll merge this one -- OK, Dave?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
