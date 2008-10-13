From: Andy Fleming <afleming@freescale.com>
Subject: Re: [2.6 patch] export genphy_restart_aneg
Date: Mon, 13 Oct 2008 13:04:30 -0500
Message-ID: <5281FCAB-128C-4AE7-8241-BF748B1911CF@freescale.com>
References: <20081013171900.GK29938@cs181140183.pp.htv.fi>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@marvell.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757627AbYJMSKe@vger.kernel.org>
In-Reply-To: <20081013171900.GK29938@cs181140183.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 13, 2008, at 12:19, Adrian Bunk wrote:

> This patch fixes the following build error caused by
> commit ed94493fb38a665cebcf750dfabe8a6dd13e136f
> (mv643xx_eth: convert to phylib):
>
> <--  snip  -->
>
> ...
>  Building modules, stage 2.
>  MODPOST 1280 modules
> ERROR: "genphy_restart_aneg" [drivers/net/mv643xx_eth.ko] undefined!
> ...
> make[2]: *** [__modpost] Error 1
>
> <--  snip  -->
>
>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>


Could you get genphy_setup_forced, too?  It doesn't appear to be used,  
but it's currently in include/linux/phy.h, and not static.

Alternatively, we could change genphy_setup_forced to be static.  :)

Andy
