From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: account SYN-ACK timeouts & retransmissions
Date: Thu, 14 Jan 2010 02:03:22 -0800 (PST)
Message-ID: <20100114.020322.168786392.davem@davemloft.net>
References: <20100111.161537.85213244.davem@davemloft.net>
	<201001121855.32018.opurdila@ixiacom.com>
	<201001132307.59472.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpyatkovskiy@ixiacom.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751346Ab0ANKDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 05:03:13 -0500
In-Reply-To: <201001132307.59472.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed, 13 Jan 2010 23:07:59 +0200

> I think we lost the SynAck accounting with this commit from the netdev-vger-
> cvs tree, where tcp_syn_recv_timer was introduced:
> 
> commit 2248761e5cfcb8687563b29c77064185e7604947
> Author: davem <davem>
> Date:   Sun Nov 10 21:25:00 1996 +0000
> 
>     Merge to 2.1.8, IPV6 is here.  Also fix
>     a stupid bug in the kernel unaligned trap handler
>     where st %g0, [foo] would fail miserably.
> 
> 
> Before this, both Syns and SynAcks seems to be accounted for.

I'm convinced.

Please spin your patch with the "doing TCP socket specific
stuff in generic inet connection socket code" part fixed.

Thanks.
