From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: netcp: remove unused kconfig option and code
Date: Fri, 23 Jan 2015 22:21:20 -0800 (PST)
Message-ID: <20150123.222120.467596005244092508.davem@davemloft.net>
References: <1421781756-11151-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421781756-11151-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Tue, 20 Jan 2015 14:22:36 -0500

> Currently CPTS is built into the netcp driver even though there is no
> call out to the CPTS driver. This patch removes the dependency in Kconfig
> and remove cpts.o from the Makefile for NetCP.
> 
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> ---
>  drivers/net/ethernet/ti/Kconfig  |    2 +-
>  drivers/net/ethernet/ti/Makefile |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> index e11bcfa..824e376 100644
> --- a/drivers/net/ethernet/ti/Kconfig
> +++ b/drivers/net/ethernet/ti/Kconfig
> @@ -73,7 +73,7 @@ config TI_CPSW
>  config TI_CPTS
>  	boolean "TI Common Platform Time Sync (CPTS) Support"
>  	depends on TI_CPSW
> -	depends on TI_CPSW || TI_KEYSTONE_NET
> +	depends on TI_CPSW

Just remove the second dependency line, it's redundant because you've
made it identical to the line before it.
