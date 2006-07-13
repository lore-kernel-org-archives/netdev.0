From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: possible dos / wsize affected frozen connection length
Date: Thu, 13 Jul 2006 22:11:49 +1000
Message-ID: <E1G102n-0007pk-00@gondolin.me.apana.org.au>
References: <20060705005540.GL2344@zip.com.au>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50188 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751537AbWGMMLy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 08:11:54 -0400
To: cat@zip.com.au (CaT)
In-Reply-To: <20060705005540.GL2344@zip.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CaT <cat@zip.com.au> wrote:
> 
> I'm just wondering if connections hanging around this long are normal.
> The above has now been running for 6 days. netstat is still reporting an
> established session. netcat has not timed out. It's all just sitting
> there doing nothing.

TCP connections without keepalives can sit there for all eternity,
if your machine lasts that long :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
