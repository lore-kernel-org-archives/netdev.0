From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Mon, 02 Mar 2009 23:12:30 +0100
Message-ID: <49AC59CE.8000703@trash.net>
References: <20090226175247.5e56910f@nehalam>	<Pine.LNX.4.64.0903021427570.27363@ask.diku.dk> <20090302105310.6c247f88@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55582 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbZCBWMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 17:12:34 -0500
In-Reply-To: <20090302105310.6c247f88@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 2 Mar 2009 14:42:33 +0100 (CET)
> Jesper Dangaard Brouer <hawk@diku.dk> wrote:
> 
>> On Thu, 26 Feb 2009, Stephen Hemminger wrote:
>>
>>> This is a simple little iptables match that can be used to create the Strong
>>> End System model, that router and other non-Linux customers expect. There
>>> are management and other applications that use ping and expect to only get
>>> a response when the interface with that address is up. Normally, a Linux
>>> system will respond to a packet that arrives for any of the system addresses
>>> independent of which link it arrives on.
>> Is this no almost the same as:
>>
>>   echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
>>
>>
> 
> That doesn't work when system already has an ARP entry and link goes down.

I think it would make sense to define the differences in behaviour
that are expected when acting according to the strict host model.
It very unlikely that all of this can be achieved with iptables,
and if what can be done is still useful, the limitations should be
known.
