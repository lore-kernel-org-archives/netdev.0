From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] skb: Propagate pfmemalloc on skb from head page only
Date: Thu, 14 Mar 2013 18:36:05 +0400
Message-ID: <5141E055.9000309@parallels.com>
References: <5141D0C4.70409@parallels.com>  <1363270569.29475.11.camel@edumazet-glaptop>  <5141DD72.6030906@parallels.com> <1363271649.29475.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Mel Gorman <mgorman@suse.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	stable@kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21931 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756123Ab3CNOhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 10:37:35 -0400
In-Reply-To: <1363271649.29475.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2013 06:34 PM, Eric Dumazet wrote:
> On Thu, 2013-03-14 at 18:23 +0400, Pavel Emelyanov wrote:
> 
>> Presumably you're right, but I don't understand how :( In order to trigger
>> this, we should have a huge page, that gets linked to an skb _before_ it
>> enters the TCP receive path. How can this happen when doing sendmsg/recvmsg?
> 
> Not only huge pages.
> 
> network now uses order-3 pages in both transmit and receive paths.

Ah, indeed! Thanks, Eric.
