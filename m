From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: auto corking
Date: Fri, 06 Dec 2013 08:06:27 -0800
Message-ID: <52A1F603.2030208@hp.com>
References: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7467@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:7687 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507Ab3LFQGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 11:06:31 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7467@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 02:30 AM, David Laight wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> With the introduction of TCP Small Queues, TSO auto sizing, and TCP
>> pacing, we can implement Automatic Corking in the kernel, to help
>> applications doing small write()/sendmsg() to TCP sockets.
>
> Presumably this has the greatest effect on connections with Nagle
> disabled?

I was wondering why Nagle didn't catch these things as well.  The 
netperf command line Eric provided though didn't include the 
test-specific -D option that would have disabled Nagle.  At least not 
unless the "super_netperf" wrapper was adding it.

So, why doesn't Nagle catch what is presumably a sub-MSS send while 
there is data outstanding on the connection?

rick jones
