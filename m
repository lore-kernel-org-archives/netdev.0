From: David Miller <davem@davemloft.net>
Subject: Re: qdisc and down links (regression)
Date: Fri, 08 Aug 2008 16:11:22 -0700 (PDT)
Message-ID: <20080808.161122.56668452.davem@davemloft.net>
References: <20080807.154735.148985698.davem@davemloft.net>
	<20080807.185024.155026077.davem@davemloft.net>
	<20080808143201.009caf54@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vgr.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41596
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764843AbYHHXLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 19:11:21 -0400
In-Reply-To: <20080808143201.009caf54@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Fri, 8 Aug 2008 14:32:01 -0700

> On Thu, 07 Aug 2008 18:50:24 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > This should fix it, let me know if it doesn't:
> 
> It fixes it for qdisc but not for ingress filters
> 
> # tc qdisc add dev eth0 handle ffff: ingress
> # tc filter add dev eth0 parent ffff: protocol ip \
>    prio 50 u32 match ip src 0.0.0.0/0 police rate 800kbit burst 10k drop flowid :1
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
> 
> Another problem is that the ingress qdisc can no longer be deleted
> successfully.

Thanks, I'll take a look at this.
