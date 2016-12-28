From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: handle no dst on skb in icmp6_send
Date: Tue, 27 Dec 2016 21:36:36 -0500 (EST)
Message-ID: <20161227.213636.1101620491173588415.davem@davemloft.net>
References: <1480301573-21183-1-git-send-email-dsa@cumulusnetworks.com>
        <20161128.161344.1778661062306703117.davem@davemloft.net>
        <1481205857.4073547.812616921.223287BE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        andreyknvl@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57308 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750722AbcL1Cgi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 21:36:38 -0500
In-Reply-To: <1481205857.4073547.812616921.223287BE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 08 Dec 2016 15:04:17 +0100

> Hello David,
> 
> On Mon, Nov 28, 2016, at 22:13, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Sun, 27 Nov 2016 18:52:53 -0800
>> 
>> > Andrey reported the following while fuzzing the kernel with syzkaller:
>>  ...
>> > icmp6_send / icmpv6_send is invoked for both rx and tx paths. In both
>> > cases the dst->dev should be preferred for determining the L3 domain
>> > if the dst has been set on the skb. Fallback to the skb->dev if it has
>> > not. This covers the case reported here where icmp6_send is invoked on
>> > Rx before the route lookup.
>> > 
>> > Fixes: 5d41ce29e ("net: icmp6_send should use dst dev to determine L3 domain")
>> > Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> 
>> Applied, thanks David.
> 
> could you queue this patch up for stable. You can remotely kill machines
> with this bug.

Sure, queued up, thanks.
