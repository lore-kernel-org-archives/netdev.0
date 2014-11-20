From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Thu, 20 Nov 2014 08:59:44 +0100
Message-ID: <20141120075943.GU6390@secunet.com>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
 <20141112084138.GL6390@secunet.com>
 <20141115031549.GA19208@gondor.apana.org.au>
 <20141120072650.GT6390@secunet.com>
 <20141120074342.GA29544@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ming Liu <ming.liu@windriver.com>, <davem@davemloft.net>,
	<ying.xue@windriver.com>, <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37703 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756545AbaKTH76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 02:59:58 -0500
Content-Disposition: inline
In-Reply-To: <20141120074342.GA29544@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 03:43:42PM +0800, Herbert Xu wrote:
> On Thu, Nov 20, 2014 at 08:26:51AM +0100, Steffen Klassert wrote:
> >
> > What about to use a fallback algorithm that does not need to touch
> > FPU/SIMD in such cases? We would not need cryptd at all and it would
> > keep the requests in the right order because we don't defer them.
> 
> This would be bad for throughput since the fallback is many orders
> of magnitude slower than aesni.

Sure, but could be an option if this is really a rare case.

Anyway, I don't mind too much about the solution as long as we
get it to work :)
