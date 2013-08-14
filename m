From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net-next ] xfrm: Update xfrm_state lifetime expire
 after clock_was_set
Date: Wed, 14 Aug 2013 13:04:23 +0200
Message-ID: <20130814110422.GH26773@secunet.com>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com>
 <1375866296-15079-3-git-send-email-fan.du@windriver.com>
 <520B14EA.4080903@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59860 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134Ab3HNLE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 07:04:29 -0400
Content-Disposition: inline
In-Reply-To: <520B14EA.4080903@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 01:26:02PM +0800, Fan Du wrote:
> 
> From bf282199fd172d1bbc6dcd0e38d1b8fc2192e5f5 Mon Sep 17 00:00:00 2001
> From: Fan Du <fan.du@windriver.com>
> Date: Wed, 14 Aug 2013 12:59:11 +0800
> Subject: [PATCHv3 net-next ] xfrm: Update xfrm_state lifetime expire after clock_was_set
> 
> After clock_was_set called to set new time or host resume from suspend
> state. Notify IKED with soft timeout for SAs which haven't reach its
> soft timeout limit. For those dying SAs, arrange them to hard expire.
> 
> This modification is characterized by SA is sensible to any degree of
> clock changes while as SA lifetime is marked by second.
> 
> Another point is clock_was_set is traversing all net name space to
> update SA time while holding rtnl_lock, it may not scale very well.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> 
> v3:
>   - Fix lockdep complaint about circular locking with trying to acquire
>     state->clock while holding xfrm_state_lock.

Fan, please resubmit the whole patchset and not single patches from a
patchset. Also, please Cc Thomas Gleixner for review of the hrtimer
changes when you resubmit.

Thanks!
