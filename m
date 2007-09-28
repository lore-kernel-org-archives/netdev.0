From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Clean up redundant PHY write line for ULi526x Ethernet
 driver
Date: Thu, 27 Sep 2007 23:36:58 -0400
Message-ID: <46FC76DA.6030906@garzik.org>
References: <1190624262.20089.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zang Roy-r61911 <tie-fei.zang@freescale.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	Grant Grundler <grundler@parisc-linux.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57153 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754036AbXI1DhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 23:37:03 -0400
In-Reply-To: <1190624262.20089.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zang Roy-r61911 wrote:
> From: Roy Zang <tie-fei.zang@freescale.com>
> 
> Clean up redundant PHY write line for ULi526x Ethernet
> Driver.
> 
> Signed-off-by: Roy Zang <tie-fei.zang@freescale.com>
> ---
>  drivers/net/tulip/uli526x.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
> index ca2548e..53a8e65 100644
> --- a/drivers/net/tulip/uli526x.c
> +++ b/drivers/net/tulip/uli526x.c
> @@ -1512,7 +1512,6 @@ static void uli526x_process_mode(struct uli526x_board_info *db)
>  			case ULI526X_100MFD: phy_reg = 0x2100; break;
>  			}
>  			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
> -       			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);

Kyle and Grant, I'll queue this up, unless ya'll object...

	Jeff


