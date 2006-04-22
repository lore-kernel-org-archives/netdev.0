From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 00/10] e1000: Driver fixes and update to 7.0.38-k2
Date: Sat, 22 Apr 2006 15:22:54 +1000
Message-ID: <E1FXAa6-0001Wt-00@gondolin.me.apana.org.au>
References: <443FF1A1.4000204@pobox.com>
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, Jeffrey.t.kirsher@intel.com,
	auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:59067 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1751038AbWDVTZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 15:25:03 -0400
Received: from arnor.apana.org.au (rhun.apana.org.au [64.62.148.172])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k3M5QBWe008648
	for <netdev@vger.kernel.org>; Sat, 22 Apr 2006 05:26:12 GMT
To: jgarzik@pobox.com (Jeff Garzik)
In-Reply-To: <443FF1A1.4000204@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
>> 05/10: [PATCH] Update truesize with the length of the packet for
>>                       packet split
> 
> These 10 patches look OK, but since the current kernel version is 
> 2.6.17-rc1, that means we are in "bug fix only" mode right now.
> 
> Should I (a) apply these all to netdev2-.6.git#upstream, queueing them 
> for 2.6.18, or (b) let you split the submission into two parts, bug 
> fixes only and everything else?

It turns out that the truesize patch is pretty important as otherwise
most of TCP receive socket buffer accounting falls apart.  So it should
probably go into 2.6.17 and even 2.6.16-stable.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
