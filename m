From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/phy: micrel: Reenable interrupts during resume
Date: Fri, 31 Jul 2015 00:22:04 -0700 (PDT)
Message-ID: <20150731.002204.2044640569422262574.davem@davemloft.net>
References: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
	<20150730.100034.1983500409184401997.davem@davemloft.net>
	<20150730230905.GA9355@nathan3500-linux-VM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nathan.sullivan@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150730230905.GA9355@nathan3500-linux-VM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>
Date: Thu, 30 Jul 2015 18:09:05 -0500

> On Thu, Jul 30, 2015 at 10:00:34AM -0700, David Miller wrote:
>> From: Nathan Sullivan <nathan.sullivan@ni.com>
>> Date: Thu, 30 Jul 2015 10:15:48 -0500
>> 
>> > Changes for V2: Actually make sure it compiles this time.
>> 
>> If V1 didn't compile, even for you, then I have a big problem.
>> 
>> And that problem is that you didn't test this change at all.
> 
> Sorry about that, I have tested it against 3.14, which is why I had
> the older interrupt function in v1.  On HEAD, the phy no longer
> suspends when ethernet goes down on our hardware - I'm still working
> on figuring out why.  I'm also surprised no one noticed this behavior
> before I did, but if the phy never goes into suspend you wouldn't.

I think you should sort out the PHY suspending issue before we move
forward with this patch.
