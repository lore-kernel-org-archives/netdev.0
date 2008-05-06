From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] 3c980-TX needs EXTRA_PREAMBLE
Date: Tue, 06 May 2008 12:23:01 -0400
Message-ID: <482085E5.6030900@pobox.com>
References: <12099888891786-git-send-email-klassert@mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gunnar Larisch <Gunnar.Larisch@gmx.de>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41395 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbYEFQXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:23:06 -0400
In-Reply-To: <12099888891786-git-send-email-klassert@mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen Klassert wrote:
> From: Gunnar Larisch <Gunnar.Larisch@gmx.de>
> 
> The ethernet card 3c980-TX needs a mdio_sync() to initialize the ethernet
> properly. This is forced by adding an EXTRA_PREAMBLE to its drv_flags.
> 
> Without this, the driver did not reconnect after a link loss.
> 
> Signed-off-by: Gunnar Larisch <Gunnar.Larisch@gmx.de>
> Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> ---
>  drivers/net/3c59x.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index 6f8e7d4..e93c378 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -319,7 +319,7 @@ static struct vortex_chip_info {
>  	{"3c920B-EMB-WNM (ATI Radeon 9100 IGP)",
>  	 PCI_USES_MASTER, IS_TORNADO|HAS_MII|HAS_HWCKSM, 128, },
>  	{"3c980 Cyclone",
> -	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
> +	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
>  
>  	{"3c980C Python-T",

applied 1-2


