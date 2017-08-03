From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: fix null pointer dereference on state and tmpl
 sort
Date: Thu, 3 Aug 2017 13:05:02 +0200
Message-ID: <20170803110502.GK2631@secunet.com>
References: <20170801142146.8588-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>,
        <davem@davemloft.net>
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48944 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751208AbdHCLFF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 07:05:05 -0400
Content-Disposition: inline
In-Reply-To: <20170801142146.8588-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 01, 2017 at 11:21:46PM +0900, Koichiro Den wrote:
> Creating sub policy that matches the same outer flow as main policy does
> leads to a null pointer dereference if the outer mode's family is ipv4.
> For userspace compatibility, this patch just eliminates the crash i.e.,
> does not introduce any new sorting rule, which would fruitlessly affect
> all but the aforementioned case.
> 
> Signed-off-by: Koichiro Den <den@klaipeden.com>

Applied to the ipsec tree, thanks!
