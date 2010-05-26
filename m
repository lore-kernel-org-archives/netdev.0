From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 15:29:10 -0700
Message-ID: <4BFDA0B6.8030701@hp.com>
References: <87fx1e1sat.fsf@basil.nowhere.org>	<20100526.140818.245406045.davem@davemloft.net>	<20100526212745.GC24615@basil.fritz.box> <20100526.151014.70204145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, ycheng@google.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:4943 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933566Ab0EZW3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 18:29:14 -0400
In-Reply-To: <20100526.151014.70204145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Wed, 26 May 2010 23:27:45 +0200
> 
>>As I understand the idea was that the application knows
>>what flows belong to a single peer and wants to have
>>a single cwnd for all of those. Perhaps there would
>>be a way to generalize that to tell it to the kernel.
>>
>>e.g. have a "peer id"  that is known by applications
>>and the kernel could manage cwnds shared between connections
>>associated with the same peer id?

Then all the app does is say "I'am in peer id foo" right?  Is that really that 
much different from making the setsockopt() call for a different cwnd value? 
Particularly if say the limit were not a global sysctl, but based on the 
existing per-route value (perhaps expanded to have a min, max and default?)

>>Just an idea, I admit I haven't thought very deeply
>>about this. Feel free to poke holes into it.
> 
> Yes, a CWND "domain" that can include multiple sockets is
> something that might gain some traction.
> 
> The "domain" could just simply be the tuple {process,peer-IP}

Name or PID?

rick jones
