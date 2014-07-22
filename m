From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next 2/3] ethtool: add rx_copybreak support
Date: Wed, 23 Jul 2014 00:05:55 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1407230004150.15542@ws.cisco>
References: <1406050268-13329-1-git-send-email-_govind@gmx.com>  <1406050268-13329-3-git-send-email-_govind@gmx.com> <1406051145.7427.2.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:63712 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756183AbaGVSgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 14:36:20 -0400
In-Reply-To: <1406051145.7427.2.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jul 2014, Ben Hutchings wrote:

> On Tue, 2014-07-22 at 23:01 +0530, Govindarajulu Varadarajan wrote:
>> This patch adds rx_copybreak support to ethtool.h header file.
>> This is used to show/set rx_copybreak using ethtool.
>>
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>> ---
>>  include/uapi/linux/ethtool.h | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
>> index e3c7a71..d2912ad 100644
>> --- a/include/uapi/linux/ethtool.h
>> +++ b/include/uapi/linux/ethtool.h
>> @@ -433,10 +433,12 @@ struct ethtool_ringparam {
>>  	__u32	rx_mini_max_pending;
>>  	__u32	rx_jumbo_max_pending;
>>  	__u32	tx_max_pending;
>> +	__u32	rx_max_copybreak_pending;
>>  	__u32	rx_pending;
>>  	__u32	rx_mini_pending;
>>  	__u32	rx_jumbo_pending;
>>  	__u32	tx_pending;
>> +	__u32	rx_copybreak_pending;
>>  };
>>
>>  /**
>
> No, you can't rearrange UAPI structures like this.
>

So I will move these 2 variables to the end of the struct?
Also in ethtool-copy.h in ethtool.

Thanks
