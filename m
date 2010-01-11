From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: account SYN-ACK timeouts & retransmissions
Date: Tue, 12 Jan 2010 00:16:33 +0200
Message-ID: <201001120016.33550.opurdila@ixiacom.com>
References: <1262808658-29346-1-git-send-email-opurdila@ixiacom.com> <20100107.172507.04893002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpyatkovskiy@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:32225 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751880Ab0AKWUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 17:20:01 -0500
In-Reply-To: <20100107.172507.04893002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 January 2010 03:25:07 you wrote:
> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Wed,  6 Jan 2010 22:10:58 +0200
> 
> > Signed-off-by: Maksim Pyatkovskiy <mpyatkovskiy@ixiacom.com>
> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> 
> RETRANSSEGS is meant to count data segments retransmits, not pure
> control frames.
> 
> Similarly for TCPTIMEOUTS, it's mean for data retransmit timeouts.
> 
> If you overload these statistics with other similar events, they
> become less meaningful.
> 

But we do increment RETRANSSEGS & TCPTIMEOUTS for SYNs. This creates an 
imbalance in client/server stats which makes things harder to diagnose.

> Finally, bumping TCP specific statistics from the generic INET
> connection oriented socket code is a huge no-no.  That code is
> written to be protocol agnostic.
> 

Fair point, I'll fix that up in the next version.
