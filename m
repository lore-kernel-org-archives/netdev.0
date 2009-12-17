From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
 vhost-net
Date: Thu, 17 Dec 2009 23:41:54 +0100
Message-ID: <20091217224154.GA3769@ami.dom.local>
References: <20091217112754.GA7755@ff.dom.local>
 <20091217114535.GA30429@gondor.apana.org.au>
 <20091217114937.GA30503@gondor.apana.org.au>
 <20091217120856.GA30774@gondor.apana.org.au>
 <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
 <20091217134408.GB31964@gondor.apana.org.au>
 <OF6A94FA41.B9EF2995-ON6525768F.004B99AC-6525768F.004F1634@in.ibm.com>
 <20091217143635.GA388@gondor.apana.org.au>
 <1261086608.26700.149.camel@w-sridhar.beaverton.ibm.com>
 <1261088890.26700.158.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:46322 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936748AbZLQWm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 17:42:26 -0500
Received: by fxm21 with SMTP id 21so2368484fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 14:42:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1261088890.26700.158.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 02:28:10PM -0800, Sridhar Samudrala wrote:
> Another interesting observation that Jarek pointed out is that if we drop skb's, i guess
> it is causing TCP to backoff and enabling TCP GSO code to send much larger packets(64K 
> compared to 16K). So although the throughput is higher, packets/sec is less in that
> case.

Maybe you're right, but there would be useful to have TCP-independent
tests to compare, or at least without such impact, so with GSO disabled.

Jarek P.
