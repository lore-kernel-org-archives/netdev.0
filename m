From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected on CPU#0!)
Date: Fri, 22 Dec 2006 13:53:27 +0100
Message-ID: <20061222125327.GA3138@ff.dom.local>
References: <20061222071308.GA1791@ff.dom.local> <E1GxiO6-0004kx-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:41117 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754822AbWLVMwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Dec 2006 07:52:19 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GxiO6-0004kx-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 22, 2006 at 10:16:30PM +1100, Herbert Xu wrote:
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> >
> > [PATCH] igmp: spin_lock_bh in timer
> > 
> > igmp_timer_expire() uses spin_lock(&im->lock)
> > but this lock is also taken by other igmp timers,
> > so it should be changed to bh version.
> 
> When you're in a timer BH is already disabled.  So this patch
> is redundant.

Yes, I recognized this "after the damage was done".

Thanks and regards,

Jarek P.
