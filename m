From: David Miller <davem@davemloft.net>
Subject: Re: sfq dump broken in 2.6.27-rc1
Date: Wed, 06 Aug 2008 18:13:27 -0700 (PDT)
Message-ID: <20080806.181327.139395860.davem@davemloft.net>
References: <20080806180237.4912a677@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755804AbYHGBN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 21:13:26 -0400
In-Reply-To: <20080806180237.4912a677@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Wed, 6 Aug 2008 18:02:37 -0700

> With only one sfq (on eth0), I am getting multiple results from
> 'tc qdisc ls'
> 
> # tc qdisc ls
> qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
> 
> Still bisecting, since there is no obvious reason for the sudden borkage.

Don't bother bisecting, it will take longer than the obvious
set of debug printk's you could add to net/sched/sch_api.c:tc_dump_qdisc().

Please use a "mindful" approach to debugging this instead of
a "mindless" one like bisect :-)
