From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] net: sched: kill dead code in sch_choke.c
Date: Wed, 4 Nov 2015 00:15:13 +0100
Message-ID: <20151103231513.GA26876@orbit.nwl.cc>
References: <1446573701-7585-1-git-send-email-phil@nwl.cc>
 <20151103.133244.1213287119275421272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemming@brocade.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53080 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965115AbbKCXPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 18:15:16 -0500
Content-Disposition: inline
In-Reply-To: <20151103.133244.1213287119275421272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 03, 2015 at 01:32:44PM -0500, David Miller wrote:
> From: Phil Sutter <phil@nwl.cc>
> Date: Tue,  3 Nov 2015 19:01:41 +0100
> 
> > It looks like this has never been used at all.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> Indeed, from day one this was completely unreferenced.

I found it by accident when trying to find out whether choke was
class-full or not. :)

> One downside from marking so much stuff const is that an
> unreferenced static variable won't be warned as unused if
> it's const.

Interestingly, this topic was picked up again only just two months
ago[1]. Not sure though if that could be used for kernel code with all
it's specialties.

Cheers, Phil

[1]: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=28901
