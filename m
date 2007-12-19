From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: missing dir in and dir fwd policy on 2.6.23
Date: Wed, 19 Dec 2007 15:03:02 +0800
Message-ID: <E1J4sxK-0001st-00@gondolin.me.apana.org.au>
References: <BAY103-DAV1125DF8000481F6A3CB962B2630@phx.gbl>
Cc: netdev@vger.kernel.org
To: pupilla@hotmail.com (Marco Berizzi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4595 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751299AbXLSHDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 02:03:05 -0500
In-Reply-To: <BAY103-DAV1125DF8000481F6A3CB962B2630@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi <pupilla@hotmail.com> wrote:
> Hello everybody.
> I'm experimenting a pretty strange ipsec problem with 2.6.23.x
> and openswan 2.4.11
> Here is the output from 'ip -s x p':

It's a bug in openswan but I haven't had the time to track it
down yet.  Anyway, the kernel is not involved since the management
of policies is entirely up to the user-space Key Manager.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
