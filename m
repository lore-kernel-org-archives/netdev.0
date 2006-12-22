From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected on CPU#0!)
Date: Fri, 22 Dec 2006 10:48:40 +0100
Message-ID: <20061222094840.GA2261@ff.dom.local>
References: <45889C53.8000307@candelatech.com> <20061222071308.GA1791@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:33474 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1946015AbWLVJrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Dec 2006 04:47:32 -0500
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <20061222071308.GA1791@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 22, 2006 at 08:13:08AM +0100, Jarek Poplawski wrote:
> [PATCH] igmp: spin_lock_bh in timer
> 
> igmp_timer_expire() uses spin_lock(&im->lock)
> but this lock is also taken by other igmp timers,
> so it should be changed to bh version.

... but according to theory this doesn't matter.
I was suggested by this other timers, which
probably use _bh unnecessarily.

Sorry for confusion - I withdraw this patch.

Jarek P.
