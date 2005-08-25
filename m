From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.6.12 Performance problems
Date: Thu, 25 Aug 2005 09:55:27 -0700
Message-ID: <430DF7FF.9080502@candelatech.com>
References: <20050825142647.70995.qmail@web33314.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751195AbVHYQzh@vger.kernel.org>
To: danial_thom@yahoo.com
In-Reply-To: <20050825142647.70995.qmail@web33314.mail.mud.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Danial Thom wrote:

> The tests I reported where on UP systems. Perhaps
> the default settings are better for this in 2.4,
> since that is what I used, and you used your
> hacks for both.

My modifications to the kernel are unlikely to speed anything
up, and probably will slow things down ever so slightly.

I can try with a UP kernel, but my machine at least has a single
processor.  I'm using the SMP kernel to take advantage of HT.

> Are you getting drops or overruns (or both)? I
> would assume drops is a decision to drop rather
> than an overrun which is a ring overrun. Overruns
> would imply more about performance than tuning,
> I'd think.

I was seeing lots of NIC errors...in fact, it was showing a great many
more errors than packets sent to it, so I just ignored them.

I increased the TxDescriptors and RxDescriptors and that helped a little.

Increasing the transmit queue for the NIC to 2000 also helped a little.

> I wouldn't think that HT would be appropriate for
> this sort of setup...?

2.6.11 seems to be faster when running SMP kernel on this system.
> 
> You're using a dual PCI-X NIC rather than the
> onboard ports? Supermicro runs their onboard

Of course.  Never found a motherboard yet with decent built-in
NICs.  The built-ins on this board are tg3 and they must be on
a slow bus, because they cannot go faster than about 700Mbps
(using big pkts).

I'll benchmark things again when 2.6.13 comes out and try to
get some more detailed numbers...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
