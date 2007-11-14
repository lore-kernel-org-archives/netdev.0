From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] powerpc: Fix fs_enet module build
Date: Tue, 13 Nov 2007 21:09:26 -0800 (PST)
Message-ID: <20071113.210926.97725854.davem@davemloft.net>
References: <4739EDA8.6020800@scram.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-embedded@ozlabs.org, marcelo@kvack.org,
	scottwood@freescale.com, linux-kernel@vger.kernel.org,
	jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org
To: jochen@scram.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52217
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750779AbXKNFJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:09:27 -0500
In-Reply-To: <4739EDA8.6020800@scram.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jochen Friedrich <jochen@scram.de>
Date: Tue, 13 Nov 2007 19:32:08 +0100

> If fs_enet is build as module, on PPC_CPM_NEW_BINDING platforms
> mii-fec/mii-bitbang should be build as module, as well. On other
> platforms, mii-fec/mii-bitbang must be included into the main module.
> Otherwise some symbols remain undefined. Additionally, fs_enet uses
> libphy, so add a select PHYLIB.
> 
>   Building modules, stage 2.
>   MODPOST 5 modules
> ERROR: "fs_scc_ops" [drivers/net/fs_enet/fs_enet.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> 
> Signed-off-by: Jochen Friedrich <jochen@scram.de>

This is truly ugly and creates an unnecessarily hard to
maintain and complex driver.

Please find a way to fix this for real, so that the
PPC_CPM_NEW_BINDING ifdef is not necessary at all and
things get built modular or not naturally as we handle
things for other cases like this.

THanks.
