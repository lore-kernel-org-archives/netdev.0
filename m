From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH 1/1] netdev: DM9000: remove BLACKFIN hacking in DM9000 netdev driver
Date: Thu, 16 Oct 2008 19:44:39 +0100
Message-ID: <20081016184439.GL31627@trinity.fluff.org>
References: <1224178844-12496-1-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@simtec.co.uk, davem@davemloft.net, vapier.adi@gmail.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.fluff.org ([89.145.97.151]:39147 "EHLO
	trinity.fluff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbYJPSos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 14:44:48 -0400
Content-Disposition: inline
In-Reply-To: <1224178844-12496-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2008 at 01:40:44AM +0800, Bryan Wu wrote:
> remove integer casting in the read/write IO accessors,
> because Blackfin now provides those functions
> 
> Tested-by: Javier Herrero <jherrero@hvsistemas.es>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
Acked-by: Ben Dooks <ben-linux@fluff.org>
> ---
>  drivers/net/dm9000.c |    9 ---------
>  1 files changed, 0 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index f42c23f..5a9083e 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -47,15 +47,6 @@
>  #define CARDNAME	"dm9000"
>  #define DRV_VERSION	"1.31"
>  
> -#ifdef CONFIG_BLACKFIN
> -#define readsb	insb
> -#define readsw	insw
> -#define readsl	insl
> -#define writesb	outsb
> -#define writesw	outsw
> -#define writesl	outsl
> -#endif
> -
>  /*
>   * Transmit timeout, default 5 seconds.
>   */
> -- 
> 1.5.6
> 

-- 
-- 
Ben

Q:      What's a light-year?
A:      One-third less calories than a regular year.

