From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Ethernet driver for SNI RM200/RM400 machines
Date: Tue, 08 May 2007 01:32:26 -0400
Message-ID: <46400B6A.9040307@garzik.org>
References: <20070423220010.GA9541@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54515 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967967AbXEHFc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:32:29 -0400
In-Reply-To: <20070423220010.GA9541@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Bogendoerfer wrote:
> I'm currently working on getting LINUX supported on SNI RM200/300/400
> machines (MIPS based servers and workstations). Most of the changes
> are already in Linus tree. What's now missing are some device drivers.
> One is an ethernet driver for the older EISA only RM200 and RM400
> machines. They are using an Intel 82596 ethernet chip. Currently
> there are 3 more or less different 82596 drivers in the tree, so
> I didn't want to add another modified copy. I took lasi_82596.c,
> extracted the common parts, put that in its own file and used
> that for lasi_82956.c and sni_82596.c. The patch is about 89k
> big, therefore I've placed it offline:
> 
> http://www.alpha.franken.de/patches/sni_82596.diff
> 
> The driver is tested on a HP B132 and a SNI RM400-220.
> 
> I've already looked at 82596.c, which contains a 82596 driver for
> MVME boards. It's no big deal to use lib82596.c as well for
> that driver. Right now my VME gear is not usable for testing,
> so if anybody has hardware to test such a modified driver, please
> mail me.
> 
> It would be great, if this driver could be included during the 2.6.22
> release cycle.

Email me the patch and I'll gladly review it...  In general we want new 
stuff to get some public exposure prior to upstream, though.  That 
usually means me merging into a branch that queues for release X+1, 
while automatically propagating to akpm's -mm.

	Jeff



