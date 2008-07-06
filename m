From: David Miller <davem@davemloft.net>
Subject: Re: net-sched 00/06: dynamically sized class hashes v2
Date: Sat, 05 Jul 2008 23:28:01 -0700 (PDT)
Message-ID: <20080705.232801.246222147.davem@davemloft.net>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devik@cdi.cz, jarkao2@gmail.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43646
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751442AbYGFG2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 02:28:02 -0400
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu,  3 Jul 2008 17:16:01 +0200 (MEST)

> These patches add support for dynamically sized class hash tables
> to remove a major bottleneck in qdisc filters with many classes
> when filters are not bound to classes and convert CBQ, HTB and HFSC
> to use them.
> 
> Changes since the last posting are mostly suggestions from Martin
> Devera and Jarek Poplawski:
> 
> - fix missing qdisc hash initialization in CBQ
> - use classes directly in hlist iteration instead of Qdisc_class_common
> - change qdisc_class_find to return Qdisc_class_common * instead of void *
> - new patch to remove child and sibling lists from HTB
> - all patches are tested now and considered ready for merging :)
> 
> The patches need the two filter destruction fixes that went into
> net-2.6.git to apply cleanly, so they won't apply until net-2.6.git
> is merged into net-next-2.6.git.

I like it!

Applied and pushed out to net-next-2.6, thanks!
