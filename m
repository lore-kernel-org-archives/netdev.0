From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] net: vlan: rename NETIF_F_HW_VLAN_* feature flags
 to NETIF_F_HW_VLAN_CTAG_*
Date: Fri, 19 Apr 2013 16:10:39 -0400 (EDT)
Message-ID: <20130419.161039.66628191850420006.davem@davemloft.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
	<1366373072-19621-2-git-send-email-kaber@trash.net>
	<1366402037.2716.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085Ab3DSUKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:10:41 -0400
In-Reply-To: <1366402037.2716.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 19 Apr 2013 21:07:17 +0100

> On Fri, 2013-04-19 at 14:04 +0200, Patrick McHardy wrote:
>> @@ -60,10 +60,10 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
>>  	[NETIF_F_IPV6_CSUM_BIT] =        "tx-checksum-ipv6",
>>  	[NETIF_F_HIGHDMA_BIT] =          "highdma",
>>  	[NETIF_F_FRAGLIST_BIT] =         "tx-scatter-gather-fraglist",
>> -	[NETIF_F_HW_VLAN_TX_BIT] =       "tx-vlan-hw-insert",
>> +	[NETIF_F_HW_VLAN_CTAG_TX_BIT] =  "tx-vlan-ctag-hw-insert",
>>  
>> -	[NETIF_F_HW_VLAN_RX_BIT] =       "rx-vlan-hw-parse",
>> -	[NETIF_F_HW_VLAN_FILTER_BIT] =   "rx-vlan-filter",
>> +	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =  "rx-vlan-ctag-hw-parse",
>> +	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] = "rx-vlan-ctag-filter",
>>  	[NETIF_F_VLAN_CHALLENGED_BIT] =  "vlan-challenged",
>>  	[NETIF_F_GSO_BIT] =              "tx-generic-segmentation",
>>  	[NETIF_F_LLTX_BIT] =             "tx-lockless",
> [...]
> 
> The only stable userland identifiers for these features are their names.
> So this is a userland ABI change and I don't think it's acceptable.

I think this is up for debate, but if others agree we can revert the
names and only put "stag" in the new ones.
