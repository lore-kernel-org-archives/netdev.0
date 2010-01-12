From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: account SYN-ACK timeouts & retransmissions
Date: Mon, 11 Jan 2010 16:15:37 -0800 (PST)
Message-ID: <20100111.161537.85213244.davem@davemloft.net>
References: <1262808658-29346-1-git-send-email-opurdila@ixiacom.com>
	<20100107.172507.04893002.davem@davemloft.net>
	<201001120016.33550.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpyatkovskiy@ixiacom.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54144
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753438Ab0ALAP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 19:15:28 -0500
In-Reply-To: <201001120016.33550.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 12 Jan 2010 00:16:33 +0200

> On Friday 08 January 2010 03:25:07 you wrote:
>> From: Octavian Purdila <opurdila@ixiacom.com>
>> Date: Wed,  6 Jan 2010 22:10:58 +0200
>> 
>> > Signed-off-by: Maksim Pyatkovskiy <mpyatkovskiy@ixiacom.com>
>> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
>> 
>> RETRANSSEGS is meant to count data segments retransmits, not pure
>> control frames.
>> 
>> Similarly for TCPTIMEOUTS, it's mean for data retransmit timeouts.
>> 
>> If you overload these statistics with other similar events, they
>> become less meaningful.
>> 
> 
> But we do increment RETRANSSEGS & TCPTIMEOUTS for SYNs. This creates an 
> imbalance in client/server stats which makes things harder to diagnose.

Interesting.

Can you do me a favor and look into the code history and see
if we used to account both sides?

I wonder if we accidently lost the statistic bumps when the
generic inet connection socket layer was added.
