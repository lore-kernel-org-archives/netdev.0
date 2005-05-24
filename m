From: root@smtp.nexlab.net
Subject: (no subject)
Date: Tue, 24 May 2005 11:11:55 +0200 (CEST)
Message-ID: <20050524091155.A98F9F9E8@smtp.nexlab.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients:;
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	by smtp.nexlab.net (Postfix) with ESMTP id 69107FA5F

	for <buffer@sniffo.org>; Tue, 24 May 2005 05:18:55 +0200 (CEST)

Received: from oss (localhost [127.0.0.1])

	by oss.sgi.com (8.12.10/8.12.10/SuSE Linux 0.7) with ESMTP id j4O2eUF3007815;

	Mon, 23 May 2005 19:40:30 -0700

Received: with ECARTIS (v1.0.0; list netdev); Mon, 23 May 2005 19:39:10 -0700 (PDT)

Received: from sunset.davemloft.net (dsl027-180-168.sfo1.dsl.speakeasy.net [216.27.180.168])

	by oss.sgi.com (8.12.10/8.12.10/SuSE Linux 0.7) with ESMTP id j4O2d3F3007472

	for <netdev@oss.sgi.com>; Mon, 23 May 2005 19:39:07 -0700

Received: from localhost ([127.0.0.1] ident=davem)

	by sunset.davemloft.net with esmtp (Exim 4.50)

	id 1DaPJB-0000Zl-8x; Mon, 23 May 2005 19:38:17 -0700

Date: Mon, 23 May 2005 19:38:17 -0700 (PDT)

Message-Id: <20050523.193817.112290763.davem@davemloft.net>

To: herbert@gondor.apana.org.au
Cc: netdev@oss.sgi.com
Subject: Re: [PATCH] Super TSO v3

From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050524023256.GA29242@gondor.apana.org.au>

References: <20050524003208.GA25778@gondor.apana.org.au>

	<20050523.192917.48530622.davem@davemloft.net>

	<20050524023256.GA29242@gondor.apana.org.au>

X-Mailer: Mew version 3.3 on Emacs 21.4 / Mule 5.0 (SAKAKI)

Mime-Version: 1.0

Content-Type: Text/Plain; charset=us-ascii

Content-Transfer-Encoding: 7bit

X-archive-position: 1540

X-ecartis-version: Ecartis v1.0.0

Sender: netdev-bounce@oss.sgi.com
Errors-To: netdev-bounce@oss.sgi.com
X-original-sender: davem@davemloft.net

Precedence: bulk

X-list: netdev

X-Virus-Scanned: ClamAV 0.83/892/Mon May 23 10:52:19 2005 on oss.sgi.com

X-Virus-Status: Clean



From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 May 2005 12:32:57 +1000

> True, the Nagle algorithm itself aims to do something different
> from this function.  However, the act of turning Nagle off is
> an indication that the application wants to minimise the latency
> by sending things out ASAP.  So we should either respect that
> here by not delaying the packets to increase the TSO size, or
> we'll need a new socket option to do that for TSO.

Sure, we can check tp->nonagle to turn this deferring off.

But, I bet there are folks who want traditional Nagle turned
off, yet TSO chunking enabled.
