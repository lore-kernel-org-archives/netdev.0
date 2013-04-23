From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix address check in rtnl_fdb_del
Date: Tue, 23 Apr 2013 18:29:22 -0400 (EDT)
Message-ID: <20130423.182922.1691641134127453781.davem@davemloft.net>
References: <1366749559-9868-1-git-send-email-vyasevic@redhat.com>
	<1366750075.4016.34.camel@bwh-desktop.uk.solarflarecom.com>
	<5176F76E.6070406@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	dlstevens@us.ibm.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab3DWW30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 18:29:26 -0400
In-Reply-To: <5176F76E.6070406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 23 Apr 2013 17:04:46 -0400

> On 04/23/2013 04:47 PM, Ben Hutchings wrote:
>> On Tue, 2013-04-23 at 16:39 -0400, Vlad Yasevich wrote:
>>> @@ -2192,7 +2192,7 @@ static int rtnl_fdb_del(struct sk_buff *skb,
>>> struct nlmsghdr *nlh)
>>>   	}
>>>
>>>   	addr = nla_data(tb[NDA_LLADDR]);
>>> -	if (!is_valid_ether_addr(addr)) {
>>> +	if (!is_zero_ether_addr(addr)) {
>>
>> This is the opposite of what you want.
> 
> of course you are right....  totally forgot the '!'...

Please test your patches.

If this patch is so unimportant that you don't feel inclined to test
it, it's probably not important enough for me to apply either.
