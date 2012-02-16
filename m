From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] renesas/sh_eth.c: fix linux/interrupt.h included twice
Date: Thu, 16 Feb 2012 09:58:11 +0900
Message-ID: <4F3C54A3.4000007@renesas.com>
References: <1329328483-4682-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1329328483-4682-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Danny Kukawka さんは書きました:
> Remove double include of linux/interrupt.h.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 87b6501..59524f1 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -34,7 +34,6 @@
>  #include <linux/phy.h>
>  #include <linux/cache.h>
>  #include <linux/io.h>
> -#include <linux/interrupt.h>
>  #include <linux/pm_runtime.h>
>  #include <linux/slab.h>
>  #include <linux/ethtool.h>

Acked-by: Nobuhiro Iwamatsu <Nobuhiro.iwamatsu.yj@renesas.com>

Nobuhiro
