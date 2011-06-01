From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] de2104x: use speed defines instead of number
Date: Wed, 1 Jun 2011 18:19:33 +0200
Message-ID: <20110601161932.GA2784@psychotron.redhat.com>
References: <1306937677-11101-1-git-send-email-jpirko@redhat.com>
 <1306943206.22348.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501Ab1FAQTg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 12:19:36 -0400
Content-Disposition: inline
In-Reply-To: <1306943206.22348.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 01, 2011 at 05:46:46PM CEST, bhutchings@solarflare.com wrote:
>The speed/speed_hi fields are defined to hold speed in Mbit/s, not only
>specific values.  I don't see any reason to use the names any more.

Do you mean to remove SPEED_X defines in whole code?

>
>Ben.
>
>On Wed, 2011-06-01 at 16:14 +0200, Jiri Pirko wrote:
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>>  drivers/net/tulip/de2104x.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
>> index e2f6923..1cc426d 100644
>> --- a/drivers/net/tulip/de2104x.c
>> +++ b/drivers/net/tulip/de2104x.c
>> @@ -1507,7 +1507,7 @@ static int __de_get_settings(struct de_private *de, struct ethtool_cmd *ecmd)
>>  		break;
>>  	}
>>  
>> -	ethtool_cmd_speed_set(ecmd, 10);
>> +	ethtool_cmd_speed_set(ecmd, SPEED_10);
>>  
>>  	if (dr32(MacMode) & FullDuplex)
>>  		ecmd->duplex = DUPLEX_FULL;
>> @@ -1529,7 +1529,7 @@ static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
>>  	u32 new_media;
>>  	unsigned int media_lock;
>>  
>> -	if (ethtool_cmd_speed(ecmd) != 10)
>> +	if (ethtool_cmd_speed(ecmd) != SPEED_10)
>>  		return -EINVAL;
>>  	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
>>  		return -EINVAL;
>
>-- 
>Ben Hutchings, Senior Software Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
