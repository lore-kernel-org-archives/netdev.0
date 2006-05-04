From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: latest -stable breaks Squid
Date: Thu, 04 May 2006 11:10:12 +1000
Message-ID: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au>
References: <20060503211915.GD27368@redhat.com>
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	fedora-list@list.zikzak.de, fedoralist@kotoulas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32517 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750716AbWEDBKR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 21:10:17 -0400
To: davej@redhat.com (Dave Jones)
In-Reply-To: <20060503211915.GD27368@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones <davej@redhat.com> wrote:
> 
> So I pushed out an update for Fedora Core 5 users yesterday
> that moved the kernel from 2.6.16.9 to 2.6.16.13.
> I've since heard "My network performance is awful", and worse
> yet, some apps seem broken as in the report below.
> 
> Anyone have any ideas ?

Try reverting the e1000 truesize patch.  Although the fix is 100%
correct, it might have a negative impact on user-space apps with
particuarly small rcvbuf settings.  Prior to the fix, due to the
incorrect accounting we are essentially enlarging rcvbuf by as much
as 10 times.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
