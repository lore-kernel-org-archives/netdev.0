From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] fec: remove unused #else branches
Date: Thu, 15 Jan 2009 11:17:03 +0100
Message-ID: <20090115101703.GS11228@pengutronix.de>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de> <496EB0DC.2080102@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34887 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762904AbZAOKRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 05:17:05 -0500
Content-Disposition: inline
In-Reply-To: <496EB0DC.2080102@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 01:43:24PM +1000, Greg Ungerer wrote:
> Hi Sascha,
>
> Sascha Hauer wrote:
>> The #else branches throughout this driver belong to a PowerPC 8xx for
>> which this driver is not used.
>>
>> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
>> ---
>>  drivers/net/fec.c |   94 -----------------------------------------------------
>>  1 files changed, 0 insertions(+), 94 deletions(-)
>>
>> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
>> index 7e33c12..95785ef 100644
>> --- a/drivers/net/fec.c
>> +++ b/drivers/net/fec.c
>> @@ -72,8 +72,6 @@ static unsigned int fec_hw[] = {
>>  	(MCF_MBAR+0x30000),
>>  #elif defined(CONFIG_M532x)
>>  	(MCF_MBAR+0xfc030000),
>> -#else
>> -	&(((immap_t *)IMAP_ADDR)->im_cpm.cp_fec),
>>  #endif
>>  };
>>  @@ -95,8 +93,6 @@ static unsigned char	fec_mac_default[] = {
>>  #define	FEC_FLASHMAC	(0xffe04000 + 4)
>>  #elif defined(CONFIG_MOD5272)
>>  #define FEC_FLASHMAC 	0xffc0406b
>> -#else
>> -#define	FEC_FLASHMAC	0
>>  #endif
>
> The breaks building for a few of the ColdFire targets. They
> expect FEC_FLASHMAC to be defined to something.
>
> Those cases could be fixed with "#ifdef"s around them,
> or by leaving this "#else" in place (simpler).

Ok, I'll leave this #else in.

Regards,
  Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
