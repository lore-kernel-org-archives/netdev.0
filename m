From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for June 23 (net)
Date: Thu, 23 Jun 2011 10:17:09 -0700
Message-ID: <20110623101709.1c11246d.randy.dunlap@oracle.com>
References: <20110623155431.6bfe3b40.sfr@canb.auug.org.au>
	<20110623091429.2d51b0f0.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:49141 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932313Ab1FWRRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 13:17:24 -0400
In-Reply-To: <20110623091429.2d51b0f0.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2011 09:14:29 -0700 Randy Dunlap wrote:

> On Thu, 23 Jun 2011 15:54:31 +1000 Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20110622:
> > 
> > The powerpc allyesconfig (and probably others) is still broken because we
> > now build the staging drivers and because of a commit in the net tree.
> > The breakage in Linus' tree is fixed by one of Andrew's patches above.
> > 
> > The net tree gained 2 build failures that I have left (see above).
> 
> 
> When CONFIG_INET is not enabled:
> 
> net/core/dev.c:2535: error: implicit declaration of function 'ip_is_fragment'

same problem in more places:

net/sched/sch_choke.c:184: error: implicit declaration of function 'ip_is_fragment'
net/sched/cls_rsvp.h:170: error: implicit declaration of function 'ip_is_fragment'
net/sched/cls_flow.c:124: error: implicit declaration of function 'ip_is_fragment'


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
