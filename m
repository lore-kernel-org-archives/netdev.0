From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to disable.
Date: Thu, 30 Dec 2010 22:52:30 -0800
Message-ID: <4D1D7DAE.7060504@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com> <1293750484-1161-2-git-send-email-justinmattock@gmail.com> <20101231064515.GC3733@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, devel@driverdev.osuosl.org,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ivtv-devel@ivtvdriver.org,
	linux-m68k@lists.linux-m68k.org,
	spi-devel-general@lists.sourceforge.net,
	linux-media@vger.kernel.org, Dan Carpenter <error27@gmail.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f194.google.com ([209.85.212.194]:41709 "EHLO
	mail-px0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab0LaGwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 01:52:11 -0500
In-Reply-To: <20101231064515.GC3733@angua.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2010 10:45 PM, Grant Likely wrote:
> On Thu, Dec 30, 2010 at 03:07:51PM -0800, Justin P. Mattock wrote:
>> The below patch fixes a typo "diable" to "disable". Please let me know if this
>> is correct or not.
>>
>> Signed-off-by: Justin P. Mattock<justinmattock@gmail.com>
>
> applied, thanks.
>
> g.

ahh.. thanks.. just cleared up the left out diabled that I had thought I 
forgotten(ended up separating comments and code and forgot)
>
>>
>> ---
>>   drivers/spi/dw_spi.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/spi/dw_spi.c b/drivers/spi/dw_spi.c
>> index 0838c79..7c3cf21 100644
>> --- a/drivers/spi/dw_spi.c
>> +++ b/drivers/spi/dw_spi.c
>> @@ -592,7 +592,7 @@ static void pump_transfers(unsigned long data)
>>   		spi_set_clk(dws, clk_div ? clk_div : chip->clk_div);
>>   		spi_chip_sel(dws, spi->chip_select);
>>
>> -		/* Set the interrupt mask, for poll mode just diable all int */
>> +		/* Set the interrupt mask, for poll mode just disable all int */
>>   		spi_mask_intr(dws, 0xff);
>>   		if (imask)
>>   			spi_umask_intr(dws, imask);
>> --
>> 1.6.5.2.180.gc5b3e
>>
>>
>> ------------------------------------------------------------------------------
>> Learn how Oracle Real Application Clusters (RAC) One Node allows customers
>> to consolidate database storage, standardize their database environment, and,
>> should the need arise, upgrade to a full multi-node Oracle RAC database
>> without downtime or disruption
>> http://p.sf.net/sfu/oracle-sfdevnl
>> _______________________________________________
>> spi-devel-general mailing list
>> spi-devel-general@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/spi-devel-general
>

Justin P. Mattock
