From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPVS] Fix sched registration race when checking for
 name collision
Date: Tue, 04 Dec 2007 00:45:25 -0800 (PST)
Message-ID: <20071204.004525.246971804.davem@davemloft.net>
References: <4753D631.8040005@openvz.org>
	<20071204014142.GC28582@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, devel@openvz.org, wensong@linux-vs.org,
	ja@ssi.bg
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752012AbXLDIpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 03:45:30 -0500
In-Reply-To: <20071204014142.GC28582@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Tue, 4 Dec 2007 10:41:43 +0900

> On Mon, Dec 03, 2007 at 01:10:57PM +0300, Pavel Emelyanov wrote:
> > The register_ip_vs_scheduler() checks for the scheduler with the
> > same name under the read-locked __ip_vs_sched_lock, then drops,
> > takes it for writing and puts the scheduler in list.
> > 
> > This is racy, since we can have a race window between the lock
> > being re-locked for writing.
> > 
> > The fix is to search the scheduler with the given name right under
> > the write-locked __ip_vs_sched_lock.
> 
> This looks correct to me.
> 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Also applied, thanks a lot.
