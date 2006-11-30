From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 21:07:42 +1100
Message-ID: <456EAD6E.6040709@yahoo.com.au>
References: <20061130061758.GA2003@elte.hu> <20061129.223055.05159325.davem@davemloft.net> <20061130064758.GD2003@elte.hu> <20061129.231258.65649383.davem@davemloft.net> <20061130073504.GA19437@elte.hu> <20061130095232.GA8990@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	wenji@fnal.gov, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.mail.mud.yahoo.com ([209.191.85.215]:49282 "HELO
	smtp105.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S933881AbWK3KIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 05:08:35 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061130095232.GA8990@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Nov 30, 2006 at 08:35:04AM +0100, Ingo Molnar (mingo@elte.hu) wrote:

> Doesn't the provided solution is just a in-kernel variant of the
> SCHED_FIFO set from userspace? Why kernel should be able to mark some
> users as having higher priority?
> What if workload of the system is targeted to not the maximum TCP
> performance, but maximum other-task performance, which will be broken
> with provided patch.

David's line of thinking for a solution sounds better to me. This patch
does not prevent the process from being preempted (for potentially a long
time), by any means.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

