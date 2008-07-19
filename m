From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: RTT metrics scaling
Date: Fri, 18 Jul 2008 23:02:57 -0700 (PDT)
Message-ID: <20080718.230257.207092590.davem@davemloft.net>
References: <20080620162234.1c2103ee@extreme>
	<20080718203431.48e16ff0@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751257AbYGSGC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 02:02:58 -0400
In-Reply-To: <20080718203431.48e16ff0@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 18 Jul 2008 20:34:31 -0700

> Some of the metrics (RTT, RTTVAR and RTAX_RTO_MIN) are stored in kernel
> units (jiffies) and this leaks out through the netlink API to user space
> where the units for jiffies are unknown.
> 
> This patches changes the kernel to convert to/from milliseconds. This changes
> the ABI, but milliseconds seemed like the most natural unit for these parameters.
> Values available via syscall in /proc/net/rt_cache and netlink will be in milliseconds.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks good, applied.
