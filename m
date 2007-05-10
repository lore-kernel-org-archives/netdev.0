From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 13:49:44 -0700
Message-ID: <46438568.1020403@hp.com>
References: <4643654F.5060207@hp.com>	<5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com>	<464370BA.3020907@hp.com> <20070510.133216.95506791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, ian.mcdonald@jandi.co.nz,
	krkumar2@in.ibm.com, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:57269 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758196AbXEJUts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 16:49:48 -0400
In-Reply-To: <20070510.133216.95506791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Thu, 10 May 2007 15:21:30 -0400
> 
> 
>>The win might be biggest on a system were a lot of applications send
>>a lot of small packets.  Some number will aggregate in the prio
>>queue and then get shoved into a driver in one go.
>>
>>But...  this is all conjecture until we see the code.
> 
> 
> Also, whatever you gain in cpu usage you'll lose in latency.
> 
> And things sending tiny frames are exactly the ones that care about
> latency.

I'd think one would only do this in those situations/places where a natural "out 
of driver" queue develops in the first place wouldn't one?

rick jones
