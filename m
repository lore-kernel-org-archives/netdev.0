From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [iproute2/ip] ip segfault with wrong key
Date: Tue, 08 Jul 2008 15:16:48 +0800
Message-ID: <E1KG7RQ-0006Om-00@gondolin.me.apana.org.au>
References: <486E189C.2010507@redhat.com>
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: mmaslano@redhat.com (Marcela Maslanova)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34615 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751609AbYGHHQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 03:16:52 -0400
In-Reply-To: <486E189C.2010507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcela Maslanova <mmaslano@redhat.com> wrote:
> 
> Wrong key in "ip xfrm state" command lead to segfault. I thought there 
> could be used only hexadecimal numbers. I'm suggesting attached patch. 
> The example of problem could be seen here: 
> https://bugzilla.redhat.com/show_bug.cgi?id=449933

I don't see why we should disallow string keys.  Let's treat the
disease instead of chopping off limbs.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
