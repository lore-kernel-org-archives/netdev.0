From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Thu, 26 Aug 2010 22:36:04 -0700 (PDT)
Message-ID: <20100826.223604.48516081.davem@davemloft.net>
References: <4C773BAF.7010809@candelatech.com>
	<20100826.213419.189712657.davem@davemloft.net>
	<4C774B8F.2030805@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45066
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751130Ab0H0Fft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 01:35:49 -0400
In-Reply-To: <4C774B8F.2030805@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 26 Aug 2010 22:22:23 -0700

> On 08/26/2010 09:34 PM, David Miller wrote:
>> From: Ben Greear<greearb@candelatech.com>
>> Date: Thu, 26 Aug 2010 21:14:39 -0700
>>
>>> I'll look into the NET_XMIT_CN, but if that propagates backpressure up
>>> through mac-vlan, then something must know how to re-start the tx
>>> logic.
>>
>> It doesn't need to, as it drops and frees up the packet.
> 
> If there were 5 pkts in the socket buffer, and the attempt to
> send the first one caused NET_XMIT_CN, then
> based on your comment below about UDP being throttled, I assume
> the other 4 are kept until later?

It only has an effect on TCP, it causes it to decrease the
congestion window limits.

I did not state that it had any effect on UDP.  Just because I
talk about UDP later in my email doesn't mean the two things
are related.
