From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 14:12:35 -0700
Message-ID: <4BD601C3.5030108@hp.com>
References: <4BD5F553.6020006@hp.com>	<20100426.134051.232750473.davem@davemloft.net>	<4BD5FC16.4070402@hp.com> <20100426.135305.15235166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:30296 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805Ab0DZVMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 17:12:38 -0400
In-Reply-To: <20100426.135305.15235166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 26 Apr 2010 13:48:22 -0700
> 
>>Do not confuse explanation with endorsement.
> 
> Ok, fair enough.
> 
> But I don't see even the "other perspective" argument being even
> valid.  Big shops still use UDP and it has to scale.

Preface - I too think it is massively stupid to ignore anything but TCP/IPv4, 
and unwise to ignore IPv6 and so on, but there is a very real reason why one of 
my email signatures reads:

"The road to hell is paved with business decisions"

> Or have they made multicast magically start working with TCP so
> they can us it to do trades on the NASDAQ?

No. How many NIC chips can NASDAQ be expected to move? 0.1%? or even 1% of the 
NIC chip market?

How many more NIC chips are in places where someone says "You sold me on 
iSCSI/FCoE/whatnot, why can't I get 'link-rate'  to/from iSCSI storage/whatnot?!"

The NIC designer is there with his finance guys breathing down his neck shouting 
"ROI Uber Alles!" and "Your budget is only this many monetary units!"  The 
system designers at the system vendors are hearing the same things from their 
own finance guys, have certain schedules, which then has them going to the NIC 
firms, who want to sell chips to the system guys "You have to be ready to ship 
by this date and your chip has to sell for no more than this."

Lather, rinse, repeat a few times and you get compromises on top of compromises.

Sometimes I think it is a wonder any of it actually works at all...

rick jones
