From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] l2tp bugfix patchset
Date: Wed, 20 Mar 2013 12:14:12 -0400 (EDT)
Message-ID: <20130320.121412.1230198756594408982.davem@davemloft.net>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227Ab3CTQOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:14:14 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Tue, 19 Mar 2013 16:11:11 +0000

> This l2tp bugfix patchset addresses a number of issues.
> 
> The first five patches in the series prevent l2tp sessions pinning an l2tp
> tunnel open.  This occurs because the l2tp tunnel is torn down in the tunnel
> socket destructor, but each session holds a tunnel socket reference which
> prevents tunnels with sessions being deleted.  The solution I've implemented
> here involves adding a .destroy hook to udp code, as discussed previously on
> netdev[1].
> 
> The subsequent seven patches address futher bugs exposed by fixing the problem
> above, or exposed through stress testing the implementation above.  Patch 11
> (avoid deadlock in l2tp stats update) isn't directly related to tunnel/session
> lifetimes, but it does prevent deadlocks on i386 kernels running on 64 bit
> hardware.
> 
> This patchset has been tested on 32 and 64 bit preempt/non-preempt kernels,
> using iproute2, openl2tp, and custom-made stress test code.
> 
> [1] http://comments.gmane.org/gmane.linux.network/259169

All applied, thanks for fixing all of these bugs Tom.
