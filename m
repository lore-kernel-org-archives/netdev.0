From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 0/1] sched: Add a new API to find the prefer idlest
 cpu
Date: Fri, 17 Aug 2012 08:39:46 -0700
Message-ID: <1345217986.16533.1.camel@oc3660625478.ibm.com>
References: <1343026634.13461.15.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	vivek@us.ibm.com, sri@us.ibm.com, sri@us.ibm.com
To: linux-kernel@vger.kernel.org, mingo@redhat.com,
	peterz@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:37656 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758269Ab2HQPj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 11:39:58 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Fri, 17 Aug 2012 11:39:57 -0400
In-Reply-To: <1343026634.13461.15.camel@oc3660625478.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ingo, Peter,

	Have you had chance to review below patch?

Thanks
Shirley

On Sun, 2012-07-22 at 23:57 -0700, Shirley Ma wrote:
> Introduce a new API to choose per-cpu thread from cgroup control cpuset
> (allowed) and preferred cpuset (local numa-node).
> 
> The receiving cpus of a networking device are not under cgroup controls.
> When such a networking device uses per-cpu thread model, the cpu which
> is chose to process the packets might not be part of cgroup cpusets
> without this API. On numa system, the preferred cpusets would help to
> reduce expensive cross memory access to/from the other node.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
> 
>  include/linux/sched.h |    2 ++
>  kernel/sched/fair.c   |   30 ++++++++++++++++++++++++++++++
>  2 files changed, 32 insertions(+), 0 deletions(-)
> 
> Thanks
> Shirley
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
