From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Tue, 23 Sep 2008 12:54:27 +0800
Message-ID: <E1Khzut-0006lv-Co@gondolin.me.apana.org.au>
References: <20080922070425.GA14572@2ka.mipt.ru>
Cc: davem@davemloft.net, johaahn@gmail.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru (Evgeniy Polyakov)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50786 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751091AbYIWEyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 00:54:39 -0400
In-Reply-To: <20080922070425.GA14572@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Sun, Sep 21, 2008 at 11:54:44PM -0700, David Miller (davem@davemloft.net) wrote:
>
>> It is in fact exactly and precisely like send().  It must even give
>> the same error return semantics as other socket data transfer calls
>> do.  See above.
> 
> That's the main difference on how you and me look at sendfile().

I think this dicussion is moot since the only time you want to use
sendfile is for bulk transfers and these days anybody designing new
applications that does bulk transfers over UDP should be taken out
and shot.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
