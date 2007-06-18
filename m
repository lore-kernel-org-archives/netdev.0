From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [CORE] Stack changes to add multiqueue hardware
 support API
Date: Mon, 18 Jun 2007 22:28:46 +0200
Message-ID: <4676EAFE.8040601@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329030D596A@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41842 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762371AbXFRU2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:28:52 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329030D596A@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>
>>>  /* Functions used for multicast support */ diff --git 
>>> a/include/linux/skbuff.h b/include/linux/skbuff.h index 
>>> e7367c7..8bcd870 100644
>>> --- a/include/linux/skbuff.h
>>> +++ b/include/linux/skbuff.h
>>> @@ -215,6 +215,7 @@ typedef unsigned char *sk_buff_data_t;
>>>   *	@pkt_type: Packet class
>>>   *	@fclone: skbuff clone status
>>>   *	@ip_summed: Driver fed us an IP checksum
>>> + *	@queue_mapping: Queue mapping for multiqueue devices
>>>   *	@priority: Packet queueing priority
>>>   *	@users: User count - see {datagram,tcp}.c
>>>   *	@protocol: Packet protocol from driver
>>> @@ -269,6 +270,7 @@ struct sk_buff {
>>>  			__u16	csum_offset;
>>>  		};
>>>  	};
>>> +	__u16			queue_mapping;
>>>   
>>>       
>> We have a 4 byte hole on 64 bit after iif where this would fit in.
>>     
>
> I'll move the variable.  Thanks for this!
>   

Or maybe move iif down to queue_mapping so both are near the
queueing related stuff.
