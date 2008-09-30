From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 00/30] Swap over NFS -v18
Date: Tue, 30 Sep 2008 14:41:16 +0200
Message-ID: <1222778476.9044.1.camel@twins>
References: <20080724140042.408642539@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:9303 "EHLO
	viefep14-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753289AbYI3Mlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 08:41:31 -0400
In-Reply-To: <20080724140042.408642539@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-07-24 at 16:00 +0200, Peter Zijlstra wrote:
> Latest version of the swap over nfs work.
> 
> Patches are against: v2.6.26-rc8-mm1
> 
> I still need to write some more comments in the reservation code.
> 
> Pekka, it uses ksize(), please have a look.
> 
> This version also deals with network namespaces.
> Two things where I could do with some suggestsion:
> 
>   - currently the sysctl code uses current->nrproxy.net_ns to obtain
>     the current network namespace
> 
>   - the ipv6 route cache code has some initialization order issues

Daniel, have you ever found time to look at my namespace issues?

