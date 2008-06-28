From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] RTT metrics scaling
Date: Fri, 27 Jun 2008 19:50:13 -0700 (PDT)
Message-ID: <20080627.195013.184418536.davem@davemloft.net>
References: <20080620162234.1c2103ee@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54916
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751916AbYF1CuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 22:50:13 -0400
In-Reply-To: <20080620162234.1c2103ee@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Jun 2008 16:22:34 -0700

> Some of the metrics (RTT, RTTVAR and RTAX_RTO_MIN) are stored in kernel
> units (jiffies) and this leaks out through the netlink API to user space
> where the units for jiffies are unknown.
> 
> This patches changes the kernel to convert to/from milliseconds. This changes
> the ABI, but milliseconds seemed like the most natural unit for these parameters.
> 
> This patch is for comment only, just to show how it would be implemented.
> I will update it after testing more.

No real objection.

But aren't we approaching microsecond RTT's soon? :-) (yes, I know in
TCP we min clamp at 200ms RTT, but that clamp we probably want to
remove soon)

If you don't think that's worth worrying about, I'll apply this patch.

Thanks.
