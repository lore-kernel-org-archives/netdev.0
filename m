From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6]: nl80211: Eliminate reference to BUS_ID_SIZE.
Date: Thu, 28 May 2009 01:08:30 -0700 (PDT)
Message-ID: <20090528.010830.45004716.davem@davemloft.net>
References: <20090526.213959.50107146.davem@davemloft.net>
	<1243495643.16631.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kay.sievers@vrfy.org, greg@kroah.com,
	johannes@sipsolutions.net
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60064
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752863AbZE1IIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 04:08:31 -0400
In-Reply-To: <1243495643.16631.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 28 May 2009 09:27:23 +0200

>> @@ -57,7 +57,7 @@ static int get_drv_dev_by_info_ifindex(struct nlattr **attrs,
>>  static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
>>  	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
>>  	[NL80211_ATTR_WIPHY_NAME] = { .type = NLA_NUL_STRING,
>> -				      .len = BUS_ID_SIZE-1 },
>> +				      .len = 20-1 },
>>  	[NL80211_ATTR_WIPHY_TXQ_PARAMS] = { .type = NLA_NESTED },
>>  	[NL80211_ATTR_WIPHY_FREQ] = { .type = NLA_U32 },
>>  	[NL80211_ATTR_WIPHY_CHANNEL_TYPE] = { .type = NLA_U32 },
> 
> this patch is actually wrong.

It cannot be right or wrong, it is merely replacing an existing value
with the constant equivalent.  It is a change which does absolutely
nothing.

> You should remove the .len value all together since the phy name has
> no limit anymore and so shouldn't the netlink API.

Anyone is free to make that improvement.  But that's now what
I am trying to accomplish here.
