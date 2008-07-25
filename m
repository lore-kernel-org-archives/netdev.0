From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 30/30] nfs: fix various memory recursions possible with swap over NFS.
Date: Fri, 25 Jul 2008 20:15:52 +0900
Message-ID: <20080725201324.86BE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080725194517.86BB.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1216983472.7257.365.camel@twins>
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
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:35887 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755821AbYGYLUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 07:20:40 -0400
In-Reply-To: <1216983472.7257.365.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, 2008-07-25 at 19:46 +0900, KOSAKI Motohiro wrote:
> > > GFP_NOFS is not enough, since swap traffic is IO, hence fall back to GFP_NOIO.
> > 
> > this comment imply turn on GFP_NOIO, but the code is s/NOFS/NOIO/. why?
> 
> Does the misunderstanding stem from the use of 'enough'?
> 
> GFP_NOFS is _more_ permissive than GFP_NOIO in that it will initiate IO,
> just not of any filesystem data.
> 


> The problem is that previuosly NOFS was correct because that avoids
> recursion into the NFS code, it now is not, because also IO (swap) can
> lead to this recursion.


Thanks nicer explain.
So, I hope add above 3 line to patch description.



Cheers!


