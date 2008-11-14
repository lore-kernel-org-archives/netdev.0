From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
	(rmmod BUG)
Date: Fri, 14 Nov 2008 19:49:22 +0100
Message-ID: <1226688562.12092.8.camel@localhost.localdomain>
References: <20081112.041143.11487260.davem@davemloft.net>
	 <1226494179.6834.64.camel@localhost.localdomain>
	 <1226566222.6834.76.camel@localhost.localdomain>
	 <20081113.140824.156293734.davem@davemloft.net>
	 <1226666324.17392.11.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56922 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbYKNStu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 13:49:50 -0500
In-Reply-To: <1226666324.17392.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-14 at 13:38 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 2008-11-13 at 14:08 -0800, David Miller wrote:
> > I suspect that something might be changing np->num_ldg, but
> > anyways the following debugging patch should provide some
> > clues.  Please reproduce this and send the logs it generates.
> 
> Debugging the rmmod problem...
> 
> I found a strange behavior, rmmod'ing the niu driver will only cause a
> kernel BUG, if the driver was loaded at boot time.  If I remove the
> niu.ko driver from /lib/modules/2.6.28-rc4-davem/kernel/drivers/net/
> reboot the system.  After that I can load and unload the niu.ko driver
> without problems... hmmm

Perhaps this is a regression, as the problem is not in v2.6.27.

I'll start bisecting monday...

I'm not sure its a NIU driver bug, as the number of changes to niu.c is
very small since v2.6.27. (git log v2.6.27.. drivers/net/niu.c)

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
