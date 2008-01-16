From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 09:58:32 +1100
Message-ID: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
References: <1200491531.4457.91.camel@localhost>
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38206 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751802AbYAPW6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 17:58:41 -0500
In-Reply-To: <1200491531.4457.91.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal <hadi@cyberus.ca> wrote:
>
> There are two issues that are inter-mingled in there. The most important
> is pf_key not being robust on dump. The other being the accurracy of

IMHO doing significant work on af_key is a waste of time.  It has no
advantages at all over xfrm_user since neither is portable.  So we
should discourage people from using af_key wherever possible.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
