From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] enic: Make dummy rfs functions inline to fix
 !CONFIG_RFS_ACCEL build
Date: Wed, 25 Jun 2014 18:04:55 -0700 (PDT)
Message-ID: <20140625.180455.1940740529236282662.davem@davemloft.net>
References: <1403685069-20198-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403685069-20198-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 25 Jun 2014 10:31:09 +0200

> If CONFIG_RFS_ACCEL=n:
> 
> drivers/net/ethernet/cisco/enic/enic_main.c: In function 'enic_open':
> drivers/net/ethernet/cisco/enic/enic_main.c:1603:2: error: implicit declaration of function 'enic_rfs_flw_tbl_init' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/cisco/enic/enic_main.c: In function 'enic_stop':
> drivers/net/ethernet/cisco/enic/enic_main.c:1630:2: error: implicit declaration of function 'enic_rfs_flw_tbl_free' [-Werror=implicit-function-declaration]
> 
> Introduced in commit a145df23ef32c7b933875f334ba28791ee75766e ("enic: Add
> Accelerated RFS support").
> 
> Dummy functions are provided, but their prototypes are missing, causing the
> build failure.  Provide dummy static inline functions instead to fix this.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks Geert.
