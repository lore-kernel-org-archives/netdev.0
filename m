From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next] ipv6: look up neighbours on demand in ip6_finish_output2()
Date: Tue, 15 Jan 2013 10:28:02 +0800
Message-ID: <50F4BEB2.2050201@gmail.com>
References: <1358170515-1383-1-git-send-email-xiyou.wangcong@gmail.com> <20130114.133004.19237632940616685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:41236 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab3AOC2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 21:28:14 -0500
Received: by mail-pa0-f54.google.com with SMTP id bi5so2629580pad.41
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 18:28:13 -0800 (PST)
In-Reply-To: <20130114.133004.19237632940616685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2013 02:30 AM, David Miller wrote:
>
> This is a very incomplete patch.
>
> If this change were so simple, it would have been done by someone
> else a long time ago.
>
> You must, in addition to the incredibly obvious changes in the packet
> output path, completely eliminate the caching of the neighbour entry
> in the ipv6 routes themselves.
>
> This means replacing every rt6->n access or test with something
> equivalent.
>

THanks, David and Eric!

I knew this is probably incomplete, that is why I added "RFC". 
Fortunately, YOSHIFUJI just sent a more complete patch:

[RFC net-next] ipv6 route: Do not attach neighbour on route.

So, please ignore mine and use his. :)
