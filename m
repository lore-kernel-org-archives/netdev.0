From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] networking broke, ssh: connect to port 22: Protocol error
Date: Wed, 6 Feb 2008 14:11:29 +0100
Message-ID: <20080206131129.GB9950@elte.hu>
References: <20080206113829.GA14793@elte.hu> <20080206.034243.243568099.davem@davemloft.net> <20080206122248.GA5233@elte.hu> <20080206.043246.63923682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:55829 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762725AbYBFNLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 08:11:41 -0500
Content-Disposition: inline
In-Reply-To: <20080206.043246.63923682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 6 Feb 2008 13:22:48 +0100
> 
> > So no, it does not fix the problem. The config i sent is a rather 
> > generic one, it should boot on most whitebox PCs. TCP connections 
> > will fail immediately, all the time.
> 
> I suspect this got added recently with how often and how thoroughly 
> you test things :-)

yeah, although various other upstream breakages prevented real long 
randconfig series in the past 2-3 days. I'd say it's either in this pull 
from your tree:

  Author: Linus Torvalds <torvalds@woody.linux-foundation.org>
  Date:   Tue Feb 5 10:09:07 2008 -0800

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
    * git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6: (21 commits)

or perhaps in this one:

  Author: Linus Torvalds <torvalds@linux-foundation.org>
  Date:   Mon Feb 4 07:43:36 2008 -0800

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6

    * git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6: (77 commits)

i'll figure it out, it's totally reproducible so it should be easy to 
bisect. Just wanted to know whether you had anything queued up already 
for something like this.

	Ingo
