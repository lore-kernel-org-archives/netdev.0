From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv4 net] ipv6: no need to check rt->dst.error when get route
 info
Date: Mon, 31 Jul 2017 17:34:09 -0600
Message-ID: <f1e0a300-b4f1-edcb-5e00-2762609d5582@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
 <20170731.162237.142502126102802813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>, liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35651 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdGaXeL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 19:34:11 -0400
Received: by mail-pf0-f196.google.com with SMTP id q85so90618pfq.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 16:34:11 -0700 (PDT)
In-Reply-To: <20170731.162237.142502126102802813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/17 5:22 PM, David Miller wrote:
> From: Hangbin Liu <liuhangbin@gmail.com>
> Date: Fri, 28 Jul 2017 00:25:36 +0800
> 
>> After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
>> result when requested"). When we get a prohibit ertry, we will return
>> -EACCES directly instead of dump route info.
>>
>> Fix it by remove the rt->dst.error check.
> ...
>> Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> 
> David A., where are we on this?
> 

Dizzy from running in circles.


Question I posed to you Saturday morning, 8:41 MDT [1]:

"... Roopa's fibmatch patches caused a change in user behavior in IPv6
getroute for prohibit, blackhole and unreachable route entries. Opinions
on whether we should limit that new behavior to just the fibmatch lookup
in which case a patch is needed or take the new behavior and consistency
in which case nothing is needed?"

Personally, after all the discussion I think the behavior as it is right
now is best.

[1] https://www.spinics.net/lists/netdev/msg446571.html
