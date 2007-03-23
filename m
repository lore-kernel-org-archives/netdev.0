From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [NET_SCHED 01/11]: sch_netem: fix off-by-one in send time
 comparison
Date: Fri, 23 Mar 2007 09:34:35 -0700
Message-ID: <20070323093435.2402404f@freekitty>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
	<20070323133514.10264.46311.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:55997 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752082AbXCWQel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 12:34:41 -0400
In-Reply-To: <20070323133514.10264.46311.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Mar 2007 14:35:40 +0100 (MET)
Patrick McHardy <kaber@trash.net> wrote:

> [NET_SCHED]: sch_netem: fix off-by-one in send time comparison
> 
> netem checks PSCHED_TLESS(cb->time_to_send, now) to find out whether it is
> allowed to send a packet, which is equivalent to cb->time_to_send < now.
> Use !PSCHED_TLESS(now, cb->time_to_send) instead to properly handle
> cb->time_to_send == now.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
>

Thanks, I saw that earlier in another spot and fixed it.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
