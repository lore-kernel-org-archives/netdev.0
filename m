From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [GIT]: Networking
Date: Sat, 14 Jun 2008 02:39:16 -0700
Message-ID: <20080614023916.431a868d@infradead.org>
References: <20080612.211959.52937006.davem@davemloft.net>
	<20080614060320.GA18454@elte.hu>
	<20080614062758.GA23803@elte.hu>
	<20080614.001428.26649070.davem@davemloft.net>
	<20080614081656.GA27820@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35893 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbYFNQjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 12:39:32 -0400
In-Reply-To: <20080614081656.GA27820@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Jun 2008 10:16:56 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> ok, should we then remove that warning, if it's spurious?
> kerneloops.org has picked up a few other instances of this warning as
> well:
> 
>   http://www.kerneloops.org/searchfile.php?search=net%2Fsched%2Fsch_generic.c&btnG=Filename+Search

the interesting thing is that there is a clear bias on which drivers
are tripping this (r8169 is top when I counted yesterday, with sis900
second and then a long tail of nothing) that I think the WARN_ON() is
useful in addition to the always-there printk. Eg it does help in seeing
which driver is most likely to trigger this.
(Andrew also thought this would trigger a *LOT*, so far it's only a
rather modest amount, but it's waiting for Fedora or others to ship a
kernel with this in to be sure)

-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
