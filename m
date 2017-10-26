From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] ipv6: esp6: use BUG_ON instead of if condition
 followed by BUG
Date: Fri, 27 Oct 2017 06:38:36 +0800
Message-ID: <20171026223836.GB8783@gondor.apana.org.au>
References: <20171025040750.GB1999@gondor.apana.org.au>
 <20171026125106.GA13009@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:42718 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751228AbdJZWjX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 18:39:23 -0400
Content-Disposition: inline
In-Reply-To: <20171026125106.GA13009@embeddedor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 07:51:06AM -0500, Gustavo A. R. Silva wrote:
> Use BUG_ON instead of if condition followed by BUG in esp_remove_trailer.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
