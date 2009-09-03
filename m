From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH net-next-2.6] net/ethtool: Add support for the ethtool
 feature to flash firmware image from a specified file.
Date: Thu, 03 Sep 2009 01:55:56 -0400
Message-ID: <4A9F5A6C.6080600@garzik.org>
References: <20090903030241.GA19390@serverengines.com> <4A9F550D.1090105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56937 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368AbZICFz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 01:55:57 -0400
In-Reply-To: <4A9F550D.1090105@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2009 01:33 AM, Jeff Garzik wrote:
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index 90c4a36..15e4eb7 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -362,6 +362,18 @@ struct ethtool_rxnfc {
>> __u32 rule_locs[0];
>> };
>>
>> +#define ETHTOOL_FLASH_MAX_FILENAME 128
>> +enum ethtool_flash_op_type {
>> + ETHTOOL_FLASH_ALL_REGIONS = 0,
>> +};
>> +
>> +/* for passing firmware flashing related parameters */
>> +struct ethtool_flash {
>> + __u32 cmd;
>> + __u32 region;
>> + char data[ETHTOOL_FLASH_MAX_FILENAME];
>> +};
>
> It passes a _filepath_ directly into the kernel? That seems quite wrong...

doh, nevermind.  Catching up...

	Jeff



