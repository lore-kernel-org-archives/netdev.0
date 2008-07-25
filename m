From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 11/30] mm: __GFP_MEMALLOC
Date: Fri, 25 Jul 2008 18:29:04 +0900
Message-ID: <20080725180305.86A9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080724140042.408642539@chello.nl> <20080724141530.060638861@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:45640 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbYGYJbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 05:31:50 -0400
In-Reply-To: <20080724141530.060638861@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter,

> __GFP_MEMALLOC will allow the allocation to disregard the watermarks, 
> much like PF_MEMALLOC.
> 
> It allows one to pass along the memalloc state in object related allocation
> flags as opposed to task related flags, such as sk->sk_allocation.

Is this properly name?
page alloc is always "mem alloc".

you wrote comment as "Use emergency reserves" and 
this flag works to turn on ALLOC_NO_WATERMARKS.

then, __GFP_NO_WATERMARK or __GFP_EMERGENCY are better?




