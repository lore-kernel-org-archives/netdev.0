From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [Lguest] [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 11:07:05 +0200
Message-ID: <200904151107.05949.borntraeger@de.ibm.com>
References: <200903271022.38244.rusty@rustcorp.com.au> <20090415083610.GA8579@gondor.apana.org.au> <20090415084717.GA8829@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Matias Zabaljauregui <zabaljauregui@gmail.com>, odie@cs.aau.dk,
	Rusty Russell <rusty@rustcorp.com.au>, lguest@ozlabs.org,
	virtualization@lists.osdl.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:51094 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbZDOJHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 05:07:09 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n3F978wi010034
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 09:07:08 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3F977aC3567666
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 11:07:07 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3F976VZ015642
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 11:07:07 +0200
In-Reply-To: <20090415084717.GA8829@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Wednesday 15 April 2009 10:47:17 schrieb Herbert Xu:
> tun: Fix sk_sleep races when attaching/detaching
>
> As the sk_sleep wait queue actually lives in tfile, which may be
> detached from the tun device, bad things will happen when we use
> sk_sleep after detaching.
>
> Since the tun device is the persistent data structure here (when
> requested by the user), it makes much more sense to have the wait
> queue live there.  There is no reason to have it in tfile at all
> since the only time we can wait is if we have a tun attached.
> In fact we already have a wait queue in tun_struct, so we might
> as well use it.
>
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Reported-by: Eric W. Biederman <ebiederm@xmission.com>
> Reported-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
