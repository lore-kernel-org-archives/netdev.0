From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec 1/3] vti6: Don't unregister pernet ops twice on
 init errors
Date: Tue, 13 May 2014 10:35:55 +0200
Message-ID: <20140513083554.GY32371@secunet.com>
References: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
 <1399671822-12842-2-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36231 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759514AbaEMIgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 04:36:12 -0400
Content-Disposition: inline
In-Reply-To: <1399671822-12842-2-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 09, 2014 at 11:43:40PM +0200, Mathias Krause wrote:
> If we fail to register one of the xfrm protocol handlers we will
> unregister the pernet ops twice on the error exit path. This will
> probably lead to a kernel panic as the double deregistration
> leads to a double kfree().
> 
> Fix this by removing one of the calls to do it only once.
> 
> Fixes: fa9ad96d49 ("vti6: Update the ipv6 side to use its own...")
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied to the ipsec tree, thanks!
