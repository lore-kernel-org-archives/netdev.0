From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] sfc: Correct address of gPXE boot configuration in
 EEPROM
Date: Thu, 06 Nov 2008 00:38:25 -0500
Message-ID: <491282D1.10401@garzik.org>
References: <20081104203244.GX7331@solarflare.com> <4912824F.6030604@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39860 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787AbYKFFi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 00:38:29 -0500
In-Reply-To: <4912824F.6030604@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Ben Hutchings wrote:
>> Due to a hardware bug, the originally assigned range cannot reliably
>> be used for boot configuration and must not be modifiable through
>> ethtool.
>>
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>> ---
>>  drivers/net/sfc/ethtool.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
>> index fa98af5..cd0d087 100644
>> --- a/drivers/net/sfc/ethtool.c
>> +++ b/drivers/net/sfc/ethtool.c
>> @@ -174,8 +174,8 @@ static struct efx_ethtool_stat efx_ethtool_stats[] 
>> = {
>>  
>>  /* EEPROM range with gPXE configuration */
>>  #define EFX_ETHTOOL_EEPROM_MAGIC 0xEFAB
>> -#define EFX_ETHTOOL_EEPROM_MIN 0x100U
>> -#define EFX_ETHTOOL_EEPROM_MAX 0x400U
>> +#define EFX_ETHTOOL_EEPROM_MIN 0x800U
>> +#define EFX_ETHTOOL_EEPROM_MAX 0x1800U
> 
> this seems like something for 2.6.28-rc not 2.6.29, so why wait for 2.6.29?

nevermind, I see the other patch now...



