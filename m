From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net/fs_enet: remove redundant messages for performance
Date: Thu, 07 Aug 2008 02:11:38 -0400
Message-ID: <489A921A.2000906@garzik.org>
References: <1218006530-27173-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47897 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753871AbYHGGLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:11:43 -0400
In-Reply-To: <1218006530-27173-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Yang wrote:
> Currently when we do a packet flood to the Ethernet port, the console
> reports error every time when a packet is dropped.  This is too
> redundant and cost performance.  Remove message for this type of event.
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
>  drivers/net/fs_enet/mac-fcc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
> index 0a97fc2..1c7ef81 100644
> --- a/drivers/net/fs_enet/mac-fcc.c
> +++ b/drivers/net/fs_enet/mac-fcc.c
> @@ -126,7 +126,7 @@ out:
>  #define FCC_NAPI_RX_EVENT_MSK	(FCC_ENET_RXF | FCC_ENET_RXB)
>  #define FCC_RX_EVENT		(FCC_ENET_RXF)
>  #define FCC_TX_EVENT		(FCC_ENET_TXB)
> -#define FCC_ERR_EVENT_MSK	(FCC_ENET_TXE | FCC_ENET_BSY)
> +#define FCC_ERR_EVENT_MSK	(FCC_ENET_TXE)
>  

applied


