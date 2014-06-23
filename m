From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Is: automated testing before David M picks them up? Was: Re:
 [Xen-devel] [PATCH net v2] xen-netback: bookkeep number of active queues in
 our own module
Date: Mon, 23 Jun 2014 11:31:51 -0400
Message-ID: <20140623153151.GA3261@laptop.dumpdata.com>
References: <1403443901-5404-1-git-send-email-wei.liu2@citrix.com>
 <20140622.172105.1949118384610767695.davem@davemloft.net>
 <20140623084032.GU20819@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	boris.ostrovsky@oracle.com, ian.campbell@citrix.com,
	xen-devel@lists.xen.org, wei.liu2@citrix.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36007 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbaF0OX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 10:23:26 -0400
Content-Disposition: inline
In-Reply-To: <20140623084032.GU20819@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Your previous patch didn't do this, and I really am suspect as to
> > whether you functionally tested and verified this aspect of your
> > change at a ll.
> > 
> 
> I've done some testing.
> 

Hey David M,

First of sorry for hijacking this thread - but it seemed like the
perfect thread.

David Vrabel raised an interesting point is that we do have an automated
build/test system that finds bugs - and in fact the 3.16-rc1 netfront
and netback bugs were discovered by that (Boris watches them like
hawks and pounces on them immediately).

That being said - all patches that go through the Xen tree (xen/tip.git)
go through that - and also the ones that maintainers do a git pull
on (say for drivers/block/*). But for xen-net* we don't do that since
well.. it hasn't been a problem in the past and we never formulated
a policy for that. (It was easy with Jens' because he likes the
GIT PULL mechanism and we just created a branch in the tree - and I also
managed to cause some embbarasing bugs so to save my face I am now
testing it religiously).

Having said that - how do you handle such situation with sub-maintainers
wanting to do some testing before they are cleared to go your way?
