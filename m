From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [PATCH 00/29] Swap over NFS -v15
Date: Wed, 19 Dec 2007 17:22:47 -0500
Message-ID: <476999B7.1000203@tmr.com>
References: <20071214153907.770251000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:55996 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514AbXLSWEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 17:04:22 -0500
In-Reply-To: <20071214153907.770251000@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra wrote:
> Hi,
> 
> Another posting of the full swap over NFS series. 
> 
> Andrew/Linus, could we start thinking of sticking this in -mm?
> 

Two questions:
1 - what is the memory use impact on the system which don't do swap over 
NFS, such as embedded systems, and
2 - what is the advantage of this code over the two existing network 
swap approaches, swapping to NFS mounted file and swap to NBD device?

I've used the NFS file when a program was running out of memory and that 
seemed to work, people in UNYUUG have reported that the nbd swap works, 
so what's better here?

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
