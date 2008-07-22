From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fs_enet: Remove unused fields in the fs_mii_bb_platform_info
 structure.
Date: Tue, 22 Jul 2008 16:09:50 -0400
Message-ID: <48863E8E.4080308@pobox.com>
References: <200807221743.47807.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	vbordug@ru.mvista.com
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48702 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682AbYGVUJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 16:09:59 -0400
In-Reply-To: <200807221743.47807.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laurent Pinchart wrote:
> The mdio_port, mdio_bit, mdc_port and mdc_bit fields in the
> fs_mii_bb_platform_info structure are left-overs from the move to the Phy
> Abstraction Layer subsystem. They are not used anymore and can be safely
> removed.
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  include/linux/fs_enet_pd.h    |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
> index 9bc045b..decc4b5 100644
> --- a/include/linux/fs_enet_pd.h
> +++ b/include/linux/fs_enet_pd.h
> @@ -103,10 +103,6 @@ struct fs_mii_bb_platform_info {
>  	struct fs_mii_bit 	mdio_dir;
>  	struct fs_mii_bit 	mdio_dat;
>  	struct fs_mii_bit	mdc_dat;
> -	int mdio_port;	/* port & bit for MDIO */
> -	int mdio_bit;
> -	int mdc_port;	/* port & bit for MDC  */
> -	int mdc_bit;
>  	int delay;	/* delay in us         */
>  	int irq[32]; 	/* irqs per phy's */

applied


