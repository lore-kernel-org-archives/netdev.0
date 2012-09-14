From: Pablo Neira Ayuso <pablo@gnumonks.org>
Subject: Re: [PATCH] netfilter: Allow xt_nat.c and x_tables.c to compiled in
Date: Fri, 14 Sep 2012 14:08:53 +0200
Message-ID: <20120914120853.GA6056@1984>
References: <87627hfi69.fsf@xmission.com>
 <Pine.GSO.4.63.1209141353470.11622@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48931 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759576Ab2INMIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 08:08:55 -0400
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.63.1209141353470.11622@stinky-local.trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 14, 2012 at 01:54:22PM +0200, Patrick McHardy wrote:
> On Thu, 13 Sep 2012, Eric W. Biederman wrote:
> 
> >xt_init in x_tables.c must be called before xt_nat_init in xt_nat.c
> >Reorder the makefile so that x_tables.o comes before xt_nat.o in
> >netfilter.o.
> >
> >This allows me to built a kernel with both of these modules compiled in.
> 
> Thanks, we've already fixed that, the patch is queued in Pablo's tree.

It should hit Linus tree soon, David pulled the fix yesterday.
