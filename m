From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Tue, 04 Dec 2007 14:21:31 -0800
Message-ID: <4755D2EB.4000807@candelatech.com>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47559119.6070803@candelatech.com> <47559455.1080009@ee.ethz.ch> <47559763.9050408@candelatech.com> <4755C984.70906@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39413 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755115AbXLDWVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 17:21:46 -0500
In-Reply-To: <4755C984.70906@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ariane Keller wrote:

> Yes, for short-term starvation it helps certainly.
> But I'm still not convinced that it is really necessary to add more 
> buffers, because I'm not sure whether the bottleneck is really the 
> loading of data from user space to kernel space.
> Some basic tests have shown that the kernel starts loosing packets at 
> approximately the same packet rate regardless whether we use netem, or 
> netem with the trace extension.
> But if you have contrary experience I'm happy to add a parameter which 
> defines the number of buffers.

I have no numbers, so if you think it works, then that is fine with me.

If you actually run out of the trace buffers, do you just continue to
run with the last settings?  If so, that would keep up throughput
even if you are out of trace buffers...

What rates do you see, btw?  (pps, bps).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

