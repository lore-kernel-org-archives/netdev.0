From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-2.6] phylib: do EXPORT_SYMBOL on get_phy_id
Date: Thu, 22 May 2008 14:01:28 -0400
Message-ID: <4835B4F8.8060307@pobox.com>
References: <1211474630-1728-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, afleming@freescale.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36636 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756002AbYEVSBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:01:32 -0400
In-Reply-To: <1211474630-1728-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker wrote:
> Commit cac1f3c8 factored out the code for get_phy_id so that it
> could be reused in multiple places.  Turns out that some of the
> users can be modular, so we need to export this symbol as well.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  drivers/net/phy/phy_device.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index ac3c01d..16a0e7d 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -207,6 +207,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
>  
>  	return 0;
>  }
> +EXPORT_SYMBOL(get_phy_id);

applied


