From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net] ipv6: no need to check rt->dst.error when get
 route info
Date: Mon, 31 Jul 2017 16:39:14 -0700 (PDT)
Message-ID: <20170731.163914.1369233353113528757.davem@davemloft.net>
References: <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
        <20170731.162237.142502126102802813.davem@davemloft.net>
        <f1e0a300-b4f1-edcb-5e00-2762609d5582@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liuhangbin@gmail.com, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, roopa@cumulusnetworks.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdGaXjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 19:39:15 -0400
In-Reply-To: <f1e0a300-b4f1-edcb-5e00-2762609d5582@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 31 Jul 2017 17:34:09 -0600

> On 7/31/17 5:22 PM, David Miller wrote:
>> From: Hangbin Liu <liuhangbin@gmail.com>
>> Date: Fri, 28 Jul 2017 00:25:36 +0800
>> 
>>> After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
>>> result when requested"). When we get a prohibit ertry, we will return
>>> -EACCES directly instead of dump route info.
>>>
>>> Fix it by remove the rt->dst.error check.
>> ...
>>> Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
>>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>> 
>> David A., where are we on this?
>> 
> 
> Dizzy from running in circles.

:-)

> Question I posed to you Saturday morning, 8:41 MDT [1]:
> 
> "... Roopa's fibmatch patches caused a change in user behavior in IPv6
> getroute for prohibit, blackhole and unreachable route entries. Opinions
> on whether we should limit that new behavior to just the fibmatch lookup
> in which case a patch is needed or take the new behavior and consistency
> in which case nothing is needed?"
> 
> Personally, after all the discussion I think the behavior as it is right
> now is best.
> 
> [1] https://www.spinics.net/lists/netdev/msg446571.html

I agree with you that we should keep the behavior as is.
