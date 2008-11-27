From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 07/29: netns ebtables: ebtable_broute in netns
Date: Thu, 27 Nov 2008 19:28:04 +0100
Message-ID: <492EE6B4.4030900@trash.net>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet> <20081127161512.13891.85396.sendpatchset@x2.localnet> <alpine.LNX.1.10.0811271925170.21626@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56116 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbYK0S2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 13:28:07 -0500
In-Reply-To: <alpine.LNX.1.10.0811271925170.21626@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CCed Alexey]

Jan Engelhardt wrote:
> On Thursday 2008-11-27 17:15, Patrick McHardy wrote:
> 
>> commit 8157e6d16af86e4a8d31a035db7be02a8a171c26
>> Author: Alexey Dobriyan <adobriyan@gmail.com>
>> Date:   Tue Nov 4 14:29:03 2008 +0100
>>
>>    netfilter: netns ebtables: ebtable_broute in netns
>>    
>>    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>>    Signed-off-by: Patrick McHardy <kaber@trash.net>
>>
>> diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
>> index b809397..055e684 100644
>> --- a/include/net/netns/x_tables.h
>> +++ b/include/net/netns/x_tables.h
>> @@ -4,7 +4,10 @@
>> #include <linux/list.h>
>> #include <linux/netfilter.h>
>>
>> +struct ebt_table;
>> +
>> struct netns_xt {
>> 	struct list_head tables[NFPROTO_NUMPROTO];
>> +	struct ebt_table *broute_table;
>> };
>> #endif
> 
> Where are the other tables from ip and ip6? Wait, I think...
> the ebtables definitions should go to ebtables.h, just like
> the ip/ip6 ones went to [not x_tables.h].

