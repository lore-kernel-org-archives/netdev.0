From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: sfq dump broken in 2.6.27-rc1
Date: Wed, 6 Aug 2008 20:20:29 -0700
Message-ID: <20080806202029.63f25c81@extreme>
References: <20080806180237.4912a677@extreme>
	<20080806.181327.139395860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48914 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753048AbYHGDUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 23:20:31 -0400
In-Reply-To: <20080806.181327.139395860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Aug 2008 18:13:27 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Wed, 6 Aug 2008 18:02:37 -0700
> 
> > With only one sfq (on eth0), I am getting multiple results from
> > 'tc qdisc ls'
> > 
> > # tc qdisc ls
> > qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> > qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> > qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> > qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> > qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> > 
> > Still bisecting, since there is no obvious reason for the sudden borkage.
> 
> Don't bother bisecting, it will take longer than the obvious
> set of debug printk's you could add to net/sched/sch_api.c:tc_dump_qdisc().
> 
> Please use a "mindful" approach to debugging this instead of
> a "mindless" one like bisect :-)

What ever happened to "you broke it, you fix it?"
