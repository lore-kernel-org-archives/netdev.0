From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Mon, 03 Oct 2011 14:02:35 -0400
Message-ID: <6.2.5.6.2.20111003140010.05a70ed0@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.binnacle.cx ([74.95.187.105]:29736 "EHLO mx.binnacle.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932263Ab1JCSDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Oct 2011 14:03:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At 06:16 PM 10/3/2011 +0200, Eric Dumazet wrote:
>
>It seems you use 4096 2MB hugepages, and your
>machine has 1GB pages availabe, you could
>try to use them.
>
>(boot cmd : hugepagesz=1GB hugepages=8 )

Tried it and got errno 12 on the segment
allocations.  None were allocated, though
the count is six and the largest is exactly
1GB.  Don't have time to dig into it.
