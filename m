From: David Miller <davem@davemloft.net>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Thu, 11 Mar 2010 10:05:19 -0800 (PST)
Message-ID: <20100311.100519.124285161.davem@davemloft.net>
References: <1268263973.9775.95.camel@nseg_linux_HP1.broadcom.com>
	<4B9850DC.9060703@hp.com>
	<1268329796.9775.125.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, bonbons@linux-vserver.org, benli@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268329796.9775.125.camel@nseg_linux_HP1.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 11 Mar 2010 09:49:56 -0800

> 
> On Wed, 2010-03-10 at 18:09 -0800, Brian Haley wrote:
>> >> I'm able to cause a netdev_watchdog timeout by changing the coalesce
>> >> settings on my bnx2, I built a little test program for it:
>> > 
>> > Do you run this program in a loop?  How quickly do you see the NETDEV
>> > WATCHDOG?
>> 
>> It's run once, and we see it almost immediately after ETHTOOL_SCOALESCE.
> 
> What's the difference between running the test program and doing ethtool
> -C?  Do you see the issue in either case?  I don't see the issue here
> with ethtool -C.

Probably because the independent program runs faster and thus
can trigger races more easily.

In any case, you should be trying to reproduce his problem with
his test program since he went through the effort of providing
one.
