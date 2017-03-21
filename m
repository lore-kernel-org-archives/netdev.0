From: Jonas Bonn <jonas@southpole.se>
Subject: Re: [PATCH v2 1/2] gtp: rename SGSN netlink attribute
Date: Tue, 21 Mar 2017 16:10:26 +0100
Message-ID: <7eb92d97-7f36-525b-f3dc-57295adc637b@southpole.se>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170321150430.23314-1-jonas@southpole.se> <20170321150748.GA20384@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:38488 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757342AbdCUPLF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 11:11:05 -0400
In-Reply-To: <20170321150748.GA20384@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2017 04:07 PM, Pablo Neira Ayuso wrote:
> On Tue, Mar 21, 2017 at 04:04:29PM +0100, Jonas Bonn wrote:
>> diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
>> index 72a04a0..c51ebb0 100644
>> --- a/include/uapi/linux/gtp.h
>> +++ b/include/uapi/linux/gtp.h
>> @@ -19,7 +19,7 @@ enum gtp_attrs {
>>   	GTPA_LINK,
>>   	GTPA_VERSION,
>>   	GTPA_TID,	/* for GTPv0 only */
>> -	GTPA_SGSN_ADDRESS,
>> +	GTPA_PEER_ADDRESS,	/* Remote GSN peer, either SGSN or GGSN */
> We need here:
>
> #define GTPA_SGSN_ADDRESS GTPA_PEER_ADDRESS
>
> for backward compatibility. Anything that is exposed through uapi
> cannot be changed.

Yes... look a couple of lines further down...

>>   	GTPA_MS_ADDRESS,
>>   	GTPA_FLOW,
>>   	GTPA_NET_NS_FD,
>> @@ -29,5 +29,6 @@ enum gtp_attrs {
>>   	__GTPA_MAX,
>>   };
>>   #define GTPA_MAX (__GTPA_MAX + 1)
>> +#define GTPA_SGSN_ADDRESS GTPA_PEER_ADDRESS /* maintain legacy attr name */

^^^^... there it is! :)

/Jonas
>>   
>>   #endif /* _UAPI_LINUX_GTP_H_ */
>> -- 
>> 2.9.3
>>
