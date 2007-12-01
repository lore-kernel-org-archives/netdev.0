From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3][RESEND] phylib: add PHY interface modes for internal
 delay for tx and rx only
Date: Sat, 01 Dec 2007 16:33:52 -0500
Message-ID: <4751D340.6020204@pobox.com>
References: <20071126161748.9671b828.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32868 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750850AbXLAVdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:33:55 -0500
In-Reply-To: <20071126161748.9671b828.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kim Phillips wrote:
> Allow phylib specification of cases where hardware needs to configure
> PHYs for Internal Delay only on either RX or TX (not both).
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> Tested-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Acked-by: Li Yang <leoli@freescale.com>
> ---
>  include/linux/phy.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index f0742b6..e10763d 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -58,6 +58,8 @@ typedef enum {
>  	PHY_INTERFACE_MODE_RMII,
>  	PHY_INTERFACE_MODE_RGMII,
>  	PHY_INTERFACE_MODE_RGMII_ID,
> +	PHY_INTERFACE_MODE_RGMII_RXID,
> +	PHY_INTERFACE_MODE_RGMII_TXID,
>  	PHY_INTERFACE_MODE_RTBI
>  } phy_interface_t;

applied 1-3


