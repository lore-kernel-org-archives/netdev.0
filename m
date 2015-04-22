From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] be2net: log link status
Date: Wed, 22 Apr 2015 18:44:32 -0400 (EDT)
Message-ID: <20150422.184432.822632448362339441.davem@davemloft.net>
References: <1429710210-7291-1-git-send-email-ivecera@redhat.com>
	<1429711674.32612.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, netdev@vger.kernel.org,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965551AbbDVWoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 18:44:34 -0400
In-Reply-To: <1429711674.32612.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 22 Apr 2015 07:07:54 -0700

> On Wed, 2015-04-22 at 15:43 +0200, Ivan Vecera wrote:
>> @@ -658,10 +659,18 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
>>  		adapter->flags |= BE_FLAGS_LINK_STATUS_INIT;
>>  	}
>>  
>> -	if (link_status)
>> +	if (link_status) {
>> +		if (speed)
>> +			/* Print speed only when it is known */
>> +			netdev_info(netdev, "Link is Up at %d Mbps\n", speed);
> 
> signed/unsigned mismatch. %u, speed

Indeed, please fix this up and resubmit, thanks.
