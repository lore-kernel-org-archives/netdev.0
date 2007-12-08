From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2/2] cxgb3 - Parity initialization for T3C adapters
Date: Fri, 07 Dec 2007 16:14:56 -0800
Message-ID: <4759E200.3050607@chelsio.com>
References: <20071205181527.22106.73134.stgit@speedy5> <4759A6EA.1050106@garzik.org> <4759CD92.2070604@chelsio.com> <4759D6AF.5050205@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, wenxiong@us.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:26734 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbXLHAPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 19:15:10 -0500
In-Reply-To: <4759D6AF.5050205@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
>
> Divy Le Ray wrote:
> > Jeff Garzik wrote:
> >> Divy Le Ray wrote:
> >>> From: Divy Le Ray <divy@chelsio.com>
> >>>
> >>> Add parity initialization for T3C adapters.
> >>>
> >>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> >>> ---
> >>>
> >>>  drivers/net/cxgb3/adapter.h       |    1
> >>>  drivers/net/cxgb3/cxgb3_main.c    |   82 ++++++++++++
> >>>  drivers/net/cxgb3/cxgb3_offload.c |   15 ++
> >>>  drivers/net/cxgb3/regs.h          |  248
> >>> +++++++++++++++++++++++++++++++++++++
> >>>  drivers/net/cxgb3/sge.c           |   24 +++-
> >>>  drivers/net/cxgb3/t3_hw.c         |  131 +++++++++++++++++---
> >>>  6 files changed, 472 insertions(+), 29 deletions(-)
> >>
> >> dropped patches 2-3, did not apply
> >>
> >>
> >
> > Hi Jeff,
> >
> > I noticed that you applied the first one of this 3 patches series to the
> > #upstream-fixes branch.
> > These patches are intended to the #upstream (2.6.25) branch, as they are
> > built on top of the
> > last 10 patches committed - 9 from me, and the white space clean up
> > (thanks!).
> > May be this is the reason why they did not apply.
>
> Ah... you need to tell me these things.  I looked for a kernel version
> in your messages but did not see one.
>
I had put it in the introduction mail, I should have added the kernel 
version in the patch titles.
I'll do from now on.

>
> Does the patch #1 need to be reverted for 2.6.24?
>
No, it can be applied to 2.6.24.
The 2 next patches seem to apply cleanly on #upstream when patch #1 is 
popped out the patch stack.

>
> > On this topic, I have a question: how do I get to see all the netdev-2.6
> > branches ?
>
>
> git fetch -f $NETDEV_URL upstream:upstream
>
> copies the latest upstream branch from netdev-2.6.git, and stores it as
> your local upstream branch.
>
> You may do the same for #upstream-fixes too.
>

That made it.
Thanks a lot!

Cheers,
Divy
