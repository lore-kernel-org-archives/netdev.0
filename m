From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/6] pch_gbe: Validate hwtstamp_config completely
 before applying it
Date: Thu, 14 Nov 2013 03:17:43 -0500 (EST)
Message-ID: <20131114.031743.441890100175989214.davem@davemloft.net>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
	<1384389770.29151.9.camel@bwh-desktop.uk.level5networks.com>
	<20131114072011.GA4908@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438Ab3KNIRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 03:17:44 -0500
In-Reply-To: <20131114072011.GA4908@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Thu, 14 Nov 2013 08:21:37 +0100

> On Thu, Nov 14, 2013 at 12:42:50AM +0000, Ben Hutchings wrote:
>> @@ -284,6 +276,8 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
>>  		return -ERANGE;
>>  	}
>>  
>> +	adapter->hwts_tx_en = cfg.tx_type == HWTSTAMP_TX_ON;
>> +
> 
> But now there is no way to turn transmit time stamping off?

He's assigning a boolean, the result of the test:

	cfg.tx_type == HWTSTAMP_TX_ON

to hwts_tx_en, he's not assigning HWTSTAMP_TX_ON to it.
