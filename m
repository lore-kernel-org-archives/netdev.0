From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Thu, 04 Jan 2007 17:26:27 +1100
Message-ID: <E1H2M3X-0001HE-00@gondolin.me.apana.org.au>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com>
Cc: herbert@gondor.apana.org.au, greearb@candelatech.com,
	jarkao2@o2.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1282 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932296AbXADG0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 01:26:39 -0500
To: dlstevens@us.ibm.com (David Stevens)
In-Reply-To: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> wrote:
>        You're right, I don't know whether it'll fix the problem Ben saw
> or not, but it looks like the original code can do a receive before the
> in_device is fully initialized, and that, of course, is bad.
>        If the device for ip_rcv() is not the same one we were
> initializing when the receive interrupted, then the patch should have
> no effect either way -- I don't think it'll hide other problems.
>        If it's hard to reproduce (which I guess is true), then you're
> right, no soft lockup doesn't really tell us if it's fixed or not.

Actually I missed your point that the multicast locks aren't even
initialised at that point.  So this does explain the soft lock-up
and therefore your patch is clearly the correct solution.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
