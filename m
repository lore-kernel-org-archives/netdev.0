From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v2] Take care of xfrm policy when checking dst
 entries
Date: Mon, 10 Sep 2012 13:59:22 -0400
Message-ID: <504E2A7A.9000003@gmail.com>
References: <20120907.144828.97793990734588625.davem@davemloft.net> <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com> <504DFA97.7070509@gmail.com> <20120910.131829.193126565067890591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, eric.dumazet@gmail.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58616 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757197Ab2IJR70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 13:59:26 -0400
In-Reply-To: <20120910.131829.193126565067890591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2012 01:18 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevich@gmail.com>
> Date: Mon, 10 Sep 2012 10:35:03 -0400
>
>> I am not sure this is right...  This has a side-effect that when an
>> rt_cache_flush() is called, it invalidates IPv6 routes a well....
>>
>> Its all fine and good do this when a new policy is added, but not when
>> IPv4 routing table changes.
>
> I disagree.
>

So you are perfectly ok with invalidating IPv6 cache when IPv4 table 
changes, but not invalidating IPv4 cache if IPv6 table changes?

-vlad
