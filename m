From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] export genphy_restart_aneg
Date: Mon, 13 Oct 2008 11:52:05 -0700 (PDT)
Message-ID: <20081013.115205.31287539.davem@davemloft.net>
References: <20081013171900.GK29938@cs181140183.pp.htv.fi>
	<5281FCAB-128C-4AE7-8241-BF748B1911CF@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, buytenh@marvell.com, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36109
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbYJMSw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 14:52:29 -0400
In-Reply-To: <5281FCAB-128C-4AE7-8241-BF748B1911CF@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Mon, 13 Oct 2008 13:04:30 -0500

> 
> On Oct 13, 2008, at 12:19, Adrian Bunk wrote:
> 
> > This patch fixes the following build error caused by
> > commit ed94493fb38a665cebcf750dfabe8a6dd13e136f
> > (mv643xx_eth: convert to phylib):
> >
> > <--  snip  -->
> >
> > ...
> >  Building modules, stage 2.
> >  MODPOST 1280 modules
> > ERROR: "genphy_restart_aneg" [drivers/net/mv643xx_eth.ko] undefined!
> > ...
> > make[2]: *** [__modpost] Error 1
> >
> > <--  snip  -->
> >
> >
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> 
> Could you get genphy_setup_forced, too?  It doesn't appear to be used, but it's currently in include/linux/phy.h, and not static.

When there is a use we can add the export.
