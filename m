From: David Miller <davem@davemloft.net>
Subject: Re: AF_BUS socket address family
Date: Sun, 01 Jul 2012 14:45:45 -0700 (PDT)
Message-ID: <20120701.144545.1360987440451468585.davem@davemloft.net>
References: <20120630141222.60df95a5@pyramind.ukuu.org.uk>
	<20120630.173346.670086962166528527.davem@davemloft.net>
	<20120701151659.2be61475@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vincent.sanders@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120701151659.2be61475@pyramind.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Sun, 1 Jul 2012 15:16:59 +0100

>> The issue is that what to do when a receiver goes deaf is a policy
>> issue.
> 
> Something all these protocols alredy recognize and have done for years.
> The real issue for AF_BUS versus the current slow AF_UNIX approach is
> that you really need to know *who* is blocked up.
> 
> That's no different to UDP multicast and needing to know how errored the
> frame.

And the policy on what to do about such UDP multicast errors is in
userspace, which is precisely my point.
