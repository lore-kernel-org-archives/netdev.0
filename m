From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] Clean up redundant PHY write line for ULi526x Ethernet
	driver
Date: Thu, 27 Sep 2007 21:57:43 -0600
Message-ID: <20070928035743.GD14312@colo.lackof.org>
References: <1190624262.20089.7.camel@localhost.localdomain> <46FC76DA.6030906@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zang Roy-r61911 <tie-fei.zang@freescale.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	Grant Grundler <grundler@parisc-linux.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:41905 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262AbXI1ERL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 00:17:11 -0400
Content-Disposition: inline
In-Reply-To: <46FC76DA.6030906@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 11:36:58PM -0400, Jeff Garzik wrote:
> Zang Roy-r61911 wrote:
>> From: Roy Zang <tie-fei.zang@freescale.com>
>> Clean up redundant PHY write line for ULi526x Ethernet
>> Driver.
>> Signed-off-by: Roy Zang <tie-fei.zang@freescale.com>
>> ---
>>  drivers/net/tulip/uli526x.c |    1 -
>>  1 files changed, 0 insertions(+), 1 deletions(-)
>> diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
>> index ca2548e..53a8e65 100644
>> --- a/drivers/net/tulip/uli526x.c
>> +++ b/drivers/net/tulip/uli526x.c
>> @@ -1512,7 +1512,6 @@ static void uli526x_process_mode(struct 
>> uli526x_board_info *db)
>>  			case ULI526X_100MFD: phy_reg = 0x2100; break;
>>  			}
>>  			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
>> -       			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
>
> Kyle and Grant, I'll queue this up, unless ya'll object...

please do, I've already Ack'd it for akpm's tree when he sent out the
initial cc.

thanks,
grant

>
> 	Jeff
>
