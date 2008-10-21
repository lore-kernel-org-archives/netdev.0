From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] netdev: DM9000: remove BLACKFIN hacking in DM9000
 netdev driver
Date: Tue, 21 Oct 2008 02:10:47 -0400
Message-ID: <48FD7267.1000704@garzik.org>
References: <1224178844-12496-1-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, davem@davemloft.net, vapier.adi@gmail.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46188 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945AbYJUGLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 02:11:00 -0400
In-Reply-To: <1224178844-12496-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bryan Wu wrote:
> remove integer casting in the read/write IO accessors,
> because Blackfin now provides those functions
> 
> Tested-by: Javier Herrero <jherrero@hvsistemas.es>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
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

applied



