From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
Date: Thu, 02 Oct 2008 16:59:09 -0400
Message-ID: <1222981149.6129.136.camel@lts-notebook>
References: <20081002130504.927878499@chello.nl>
	 <20081002124748.638c95ff.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:14341 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104AbYJBU7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 16:59:13 -0400
In-Reply-To: <20081002124748.638c95ff.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-02 at 12:47 -0700, Andrew Morton wrote:
> On Thu, 02 Oct 2008 15:05:04 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Let's get this ball rolling...
> 
> I don't think we're really able to get any MM balls rolling until we
> get all the split-LRU stuff landed.  Is anyone testing it?  Is it good?

Andrew:

Up until the mailing list traffic and patches slowed down, I was testing
it continuously with a heavy stress load that would bring the system to
its knees before the splitlru and unevictable changes.  When it would
run for days without error [96 hours was my max run] and no further
patches came, I've concentrated on other things.

Rik and Kosaki-san have run some performance oriented tests, reported
here a while back.  Maybe they have more info.

Lee

