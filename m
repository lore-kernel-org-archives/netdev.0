From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iproute2: sch_rr support in tc
Date: Thu, 28 Jun 2007 18:40:37 +0200
Message-ID: <4683E485.8050907@trash.net>
References: <20070628162158.18762.76713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54673 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764854AbXF1Qld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:41:33 -0400
In-Reply-To: <20070628162158.18762.76713.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> This patch applies on top of Patrick McHardy's RTNETLINK
> patches to add nested compat attributes.  This is needed to maintain
> ABI for sch_{rr|prio} in the kernel with respect to tc.  A new option,
> namely multiqueue, was added to sch_prio and sch_rr.  This will allow
> a user to turn multiqueue support on for sch_prio or sch_rr at loadtime.
> Also, tc qdisc ls will display whether or not multiqueue is enabled on
> that qdisc.  When in multiqueue mode, a user can specify a value of 0 for
> bands, and the number of bands will be created to match the number of
> queues on the device.
> 
> This patch is to support the new sch_rr (round-robin) qdisc being proposed
> in NET for multiqueue network device support in the Linux network stack.
> It uses q_prio.c as the template, since the qdiscs are nearly identical,
> outside of the ->dequeue() routine.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---
> 
>  include/linux/pkt_sched.h |    9 +++
>  tc/Makefile               |    1 
>  tc/q_prio.c               |   24 +++++++--
>  tc/q_rr.c                 |  127 +++++++++++++++++++++++++++++++++++++++++++++


Since rr is not built as a module you could actually put everything
in q_prio and share the code. But I don't really care :)

