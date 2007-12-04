From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Tue, 04 Dec 2007 22:41:24 +0100
Message-ID: <4755C984.70906@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47559119.6070803@candelatech.com> <47559455.1080009@ee.ethz.ch> <47559763.9050408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:63860 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138AbXLDVl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 16:41:28 -0500
In-Reply-To: <47559763.9050408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Ben Greear wrote:
> Ariane Keller wrote:
>> I thought about that as well, but in my opinion this does not help much.
>> It's the same as before: in average every 10ms a new buffer needs to 
>> be filled.
> But, you can fill 50 or 100 at a time, so if user-space is delayed for a 
> few ms, the
> kernel still has plenty of buffers to work with until user-space gets 
> another chance.
> I'm not worried about average thoughput of user-space to kernel, just 
> random
> short-term starvation.

Yes, for short-term starvation it helps certainly.
But I'm still not convinced that it is really necessary to add more 
buffers, because I'm not sure whether the bottleneck is really the 
loading of data from user space to kernel space.
Some basic tests have shown that the kernel starts loosing packets at 
approximately the same packet rate regardless whether we use netem, or 
netem with the trace extension.
But if you have contrary experience I'm happy to add a parameter which 
defines the number of buffers.

Thanks!
