From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] net: ipv4: remove fib_weight
Date: Thu, 28 Sep 2017 07:25:57 -0600
Message-ID: <0b02a734-38da-5b65-063c-bc861509ff99@gmail.com>
References: <1506564480-20374-1-git-send-email-dsahern@gmail.com>
 <20170927.215101.2052729160923454927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38696 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752987AbdI1NZ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 09:25:58 -0400
Received: by mail-pg0-f68.google.com with SMTP id y192so833042pgd.5
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 06:25:58 -0700 (PDT)
In-Reply-To: <20170927.215101.2052729160923454927.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/27/17 10:51 PM, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Wed, 27 Sep 2017 19:08:00 -0700
> 
>> fib_weight in fib_info is set but not used. Remove it and the
>> helpers for setting it.
>>
>> Signed-off-by: David Ahern <dsahern@gmail.com>
> 
> Hmmm, I wonder then what Peter intended in commit
> 0e884c78ee19e902f300ed147083c28a0c6302f0 ("ipv4: L3 hash-based
> multipath") because that's where this came from.
> 

You can see that fib_weight is set but not used in his patch either.
Perhaps it was an early idea that was replaced by the per-nexthop
nh_upper_bound and that code was not removed.
