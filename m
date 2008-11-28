From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: netfilter 07/29: netns ebtables: ebtable_broute in netns
Date: Fri, 28 Nov 2008 11:02:08 +0300
Message-ID: <20081128080208.GB3495@x200.localdomain>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet> <20081127161512.13891.85396.sendpatchset@x2.localnet> <alpine.LNX.1.10.0811271925170.21626@fbirervta.pbzchgretzou.qr> <492EE6B4.4030900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>, davem@davemloft.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:35831 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbYK1H6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 02:58:08 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1073944ika.5
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 23:58:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <492EE6B4.4030900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2008 at 07:28:04PM +0100, Patrick McHardy wrote:
> [CCed Alexey]
>
> Jan Engelhardt wrote:
>> On Thursday 2008-11-27 17:15, Patrick McHardy wrote:
>>
>>> commit 8157e6d16af86e4a8d31a035db7be02a8a171c26
>>> Author: Alexey Dobriyan <adobriyan@gmail.com>
>>> Date:   Tue Nov 4 14:29:03 2008 +0100
>>>
>>>    netfilter: netns ebtables: ebtable_broute in netns
>>>       Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>>>    Signed-off-by: Patrick McHardy <kaber@trash.net>
>>>
>>> diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
>>> index b809397..055e684 100644
>>> --- a/include/net/netns/x_tables.h
>>> +++ b/include/net/netns/x_tables.h
>>> @@ -4,7 +4,10 @@
>>> #include <linux/list.h>
>>> #include <linux/netfilter.h>
>>>
>>> +struct ebt_table;
>>> +
>>> struct netns_xt {
>>> 	struct list_head tables[NFPROTO_NUMPROTO];
>>> +	struct ebt_table *broute_table;
>>> };
>>> #endif
>>
>> Where are the other tables from ip and ip6? Wait, I think...
>> the ebtables definitions should go to ebtables.h, just like
>> the ip/ip6 ones went to [not x_tables.h].

I haven't bothered with new file for 3 pointers.

When net.bridge.* sysctls will be made per-netns, definitely.
