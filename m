From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected on CPU#0!)
Date: Fri, 22 Dec 2006 22:16:30 +1100
Message-ID: <E1GxiO6-0004kx-00@gondolin.me.apana.org.au>
References: <20061222071308.GA1791@ff.dom.local>
Cc: greearb@candelatech.com, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3890 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1946042AbWLVLQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 06:16:57 -0500
To: jarkao2@o2.pl (Jarek Poplawski)
In-Reply-To: <20061222071308.GA1791@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski <jarkao2@o2.pl> wrote:
>
> [PATCH] igmp: spin_lock_bh in timer
> 
> igmp_timer_expire() uses spin_lock(&im->lock)
> but this lock is also taken by other igmp timers,
> so it should be changed to bh version.

When you're in a timer BH is already disabled.  So this patch
is redundant.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
