From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Lguest] [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 13:07:32 +0200
Message-ID: <49E5BFF4.3090606@trash.net>
References: <200903271022.38244.rusty@rustcorp.com.au> <1238709324.5823.8.camel@odie.local> <1239043798.27826.93.camel@zetabook> <200904081021.39877.rusty@rustcorp.com.au> <1239224319.17844.16.camel@zetabook> <49DDE91A.8060603@trash.net> <49DDF614.1060909@trash.net> <m1bpr6hqrm.fsf@fess.ebiederm.org> <49E47976.8020005@trash.net> <20090415083610.GA8579@gondor.apana.org.au> <20090415084717.GA8829@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Matias Zabaljauregui <zabaljauregui@gmail.com>, odie@cs.aau.dk,
	Rusty Russell <rusty@rustcorp.com.au>, lguest@ozlabs.org,
	virtualization@lists.osdl.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56693 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624AbZDOLHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:07:46 -0400
In-Reply-To: <20090415084717.GA8829@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Apr 15, 2009 at 04:36:10PM +0800, Herbert Xu wrote:
>> Let me whip up a patch.
> 
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

Tested and works fine, thanks Herbert.
