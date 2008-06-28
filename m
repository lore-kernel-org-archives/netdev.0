From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC] RTT metrics scaling
Date: Fri, 27 Jun 2008 22:30:07 -0700
Message-ID: <20080627223007.02eb6622@speedy>
References: <20080620162234.1c2103ee@extreme>
	<20080627.195013.184418536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59809 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071AbYF1FaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jun 2008 01:30:20 -0400
In-Reply-To: <20080627.195013.184418536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Jun 2008 19:50:13 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 20 Jun 2008 16:22:34 -0700
> 
> > Some of the metrics (RTT, RTTVAR and RTAX_RTO_MIN) are stored in kernel
> > units (jiffies) and this leaks out through the netlink API to user space
> > where the units for jiffies are unknown.
> > 
> > This patches changes the kernel to convert to/from milliseconds. This changes
> > the ABI, but milliseconds seemed like the most natural unit for these parameters.
> > 
> > This patch is for comment only, just to show how it would be implemented.
> > I will update it after testing more.
> 
> No real objection.
> 
> But aren't we approaching microsecond RTT's soon? :-) (yes, I know in
> TCP we min clamp at 200ms RTT, but that clamp we probably want to
> remove soon)

We could put in microseconds, but since it is computer off of jiffies (ie clock
ticks), the resolution wouldn't be worth it.


> If you don't think that's worth worrying about, I'll apply this patch.

Hold off it needs more testing.
