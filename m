From: Rick Jones <rick.jones2@hp.com>
Subject: Re: rtt metric only for incoming connections?
Date: Tue, 27 May 2008 11:53:38 -0700
Message-ID: <483C58B2.8080100@hp.com>
References: <20080521163815.GA5028@sc.homeunix.net>	<20080521101053.27db3495@extreme> <20080521114354.31c6807c@extreme>	<20080522103610.GB5354@sc.homeunix.net> <20080527114311.2734402b@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephane Chazelas <Stephane_Chazelas@yahoo.fr>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:20908 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757604AbYE0Sxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 14:53:42 -0400
In-Reply-To: <20080527114311.2734402b@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>Also, it seems we can't lower the initial RTO below the RFC 1122
>>default of 3 seconds. 3 seconds may be appropriate for a host
>>for which we don't know how many hops, links, satellites are
>>needed to reach it, but what about local/corporate networks
>>where it's possible to administratively know the rtt so that it
>>can be hardcoded in the routing table.
> 
> 
> Violating RFC's is not really that useful. 

Yet the RFC's are not stone tablets, and they often represent a 
"compromise" between things desirable for the great big internet and 
those someone with a bounded network might have.

> If you have a network dropping SYN packets regularly than there are
> worse problems.

That is entirely plausible.

> Relying on TCP to overcome wireless network problems is not
> a good idea.

How is it any worse than relying on TCP to overcome network congestion 
problems?-)

rick jones
