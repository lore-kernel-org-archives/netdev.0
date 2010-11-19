From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 09:21:29 -0800 (PST)
Message-ID: <20101119.092129.112602956.davem@davemloft.net>
References: <1290185759.3034.179.camel@edumazet-laptop>
	<20101119.090516.104057453.davem@davemloft.net>
	<20101119091537.5d1fed2e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hagen@jauu.net, netdev@vger.kernel.org,
	xiaosuo@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59555
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755406Ab0KSRVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 12:21:06 -0500
In-Reply-To: <20101119091537.5d1fed2e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 19 Nov 2010 09:15:37 -0800

> On Fri, 19 Nov 2010 09:05:16 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 19 Nov 2010 17:55:59 +0100
>> 
>> > Unfortunatly on x86_32 it also chose that f_k was more valuable in a cpu
>> > register and accumulator A lost its register to get a stack slot
>> > instead.
>> 
>> Ok that tradeoff is terrible, but it depends upon knowledge we haven't
>> given to the compiler (yet).
>> 
>> Let me think about this a bit...
> 
> Are 'register' modifiers a no-op on current GCC?

Yes, they are.
