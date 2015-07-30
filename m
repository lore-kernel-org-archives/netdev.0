From: David Miller <davem@davemloft.net>
Subject: Re: [[PATCH net-next v5] net/ipv6: add sysctl option
 accept_ra_min_hop_limit
Date: Thu, 30 Jul 2015 15:57:00 -0700 (PDT)
Message-ID: <20150730.155700.2101007694308260895.davem@davemloft.net>
References: <1438237722-13694-1-git-send-email-liuhangbin@gmail.com>
	<55B9C56D.2040601@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liuhangbin@gmail.com, netdev@vger.kernel.org, davem@davemloft.com,
	hannes@stressinduktion.org
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbG3W5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 18:57:01 -0400
In-Reply-To: <55B9C56D.2040601@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Date: Thu, 30 Jul 2015 15:34:21 +0900

> Hangbin Liu wrote:
>> Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
>> disabled accept hop limit from RA if it is smaller than the current hop
>> limit for security stuff. But this behavior kind of break the RFC definition.
>> 
>> RFC 4861, 6.3.4.  Processing Received Router Advertisements
>>    A Router Advertisement field (e.g., Cur Hop Limit, Reachable Time,
>>    and Retrans Timer) may contain a value denoting that it is
>>    unspecified.  In such cases, the parameter should be ignored and the
>>    host should continue using whatever value it is already using.
>> 
>>    If the received Cur Hop Limit value is non-zero, the host SHOULD set
>>    its CurHopLimit variable to the received value.
>> 
>> So add sysctl option accept_ra_min_hop_limit to let user choose the minimum
>> hop limit value they can accept from RA. And set default to 1 to meet RFC
>> standards.
>> 
>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> 
> Acked-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>

Applied, thanks everyone.
