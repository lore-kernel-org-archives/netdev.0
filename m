From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/21] net: mac80211_hwsim: convert to using
 IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 11:54:29 -0700 (PDT)
Message-ID: <20150818.115429.1070713595324669390.davem@davemloft.net>
References: <1439886649-24166-15-git-send-email-phil@nwl.cc>
	<1439886649-24166-16-git-send-email-phil@nwl.cc>
	<1439887435.2455.0.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: phil@nwl.cc, netdev@vger.kernel.org, brouer@redhat.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbbHRSya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 14:54:30 -0400
In-Reply-To: <1439887435.2455.0.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 18 Aug 2015 10:43:55 +0200

> On Tue, 2015-08-18 at 10:30 +0200, Phil Sutter wrote:
>> Signed-off-by: Phil Sutter <phil@nwl.cc>
>> Cc: Johannes Berg <johannes@sipsolutions.net>
>> ---
>>  drivers/net/wireless/mac80211_hwsim.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/wireless/mac80211_hwsim.c 
>> b/drivers/net/wireless/mac80211_hwsim.c
>> index 99e873d..a1dbcb2 100644
>> --- a/drivers/net/wireless/mac80211_hwsim.c
>> +++ b/drivers/net/wireless/mac80211_hwsim.c
>> @@ -2676,7 +2676,7 @@ static void hwsim_mon_setup(struct net_device 
>> *dev)
>>  	dev->netdev_ops = &hwsim_netdev_ops;
>>  	dev->destructor = free_netdev;
>>  	ether_setup(dev);
>> -	dev->tx_queue_len = 0;
>> +	dev->priv_flags |= IFF_NO_QUEUE;
>> 
> Fine with me; Dave, are you going to pick up the entire series
> (presumably there was one, I only got this patch)?
> 
> Note that there's no TX possible on this particular netdev anyway.

Yes, I'm going to take the full series.
