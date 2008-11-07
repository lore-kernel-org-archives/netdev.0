From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 05:46:28 +0100 (CET)
Message-ID: <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com> <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se> <20081105.151015.206163697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: daniel.blueman@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20081105.151015.206163697.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 5 Nov 2008, David Miller wrote:

> This kind of thinking just perpetuates the problem forever.

Well, I also think IPv6 breaks things for some people (mostly buggt DNS 
resolvers) but I wholly support this being default on. The ISP business is 
going in the direction of faster links and smaller interface buffers, 
meaning WRED is used less and less, thus lessening the benefit of ECN.

I see that in 
<http://www.icir.org/floyd/papers/draft-ietf-tsvwg-tcp-ecn-00.txt> there 
is a recommendation to not use ECN on retransmits, is there code right now 
(or planned) to do some kind of "ECN blackhole detection", ie if no 
response is received to SYN with ECN set, continue by sending the second 
SYN without ECN and keep this information for the duration of the TCP 
session?

If there is, I do agree with you that enabling ECN by default is a good 
idea. Without such code, I still believe there are enough broken devices 
out there that will create problems for people.

It's like the TCP option order "bug", where some devices would drop the 
packets because of buggy implementations, that was changed in Linux to 
work around others buggy code, and I see "ECN blackhole detection" as a 
similar measure.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
