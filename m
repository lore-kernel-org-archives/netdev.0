From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Configurable tap interface MTU
Date: Wed, 12 Sep 2007 11:29:42 +0800
Message-ID: <E1IVIv8-0003Uc-00@gondolin.me.apana.org.au>
References: <e6c711510709110742v4d2da644ha63b0a6d47c1230b@mail.gmail.com>
Cc: netdev@vger.kernel.org, maxk@qualcomm.com,
	linux-kernel@vger.kernel.org
To: eswierk@arastra.com (Ed Swierk)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2955 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932656AbXILD36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 23:29:58 -0400
In-Reply-To: <e6c711510709110742v4d2da644ha63b0a6d47c1230b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ed Swierk <eswierk@arastra.com> wrote:
> 
> The patch caps the MTU somewhat arbitrarily at 16000 bytes. This is
> slightly lower than the value used by the e1000 driver, so it seems
> like a safe upper limit.

Please make it 65535 without an Ethernet header and 65521
with an Ethernet header.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
