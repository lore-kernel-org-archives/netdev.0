From: Andi Kleen <andi@firstfloor.org>
Subject: Re: New qdisc monitor
Date: Fri, 02 Oct 2009 23:21:22 +0200
Message-ID: <873a61bigd.fsf@basil.nowhere.org>
References: <1254501684.2670.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: clownix <clownix@clownix.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:47307 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbZJBVVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 17:21:19 -0400
In-Reply-To: <1254501684.2670.7.camel@localhost> (clownix@clownix.net's message of "Fri, 02 Oct 2009 18:41:24 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clownix <clownix@clownix.net> writes:

> At http://clownix.net, there is a qdisc monitor based on a new sched
> qdisc named spy and a module that periodicaly sends the
> enqueues/dequeues/drops/queue-size/delays... to be plotted to the user
> world through a netlink socket.
> Note that the name of this software package is "clownix_spy", and not
> cloonix_net which is another project on the same site.

Sounds like a cool idea, but could you consider submitting the qdisc
for mainline and getting it reviewed? Out of tree kernel patches for these 
kinds of things tend to be a pain to use.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
