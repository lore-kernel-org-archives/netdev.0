From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Oops on error in pfkey_msg2xfrm_state()
Date: Thu, 15 Jun 2017 13:56:58 +0200
Message-ID: <20170615115658.GG2631@secunet.com>
References: <20170614103405.GI29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46030 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752141AbdFOL5E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 07:57:04 -0400
Content-Disposition: inline
In-Reply-To: <20170614103405.GI29394@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 01:34:05PM +0300, Dan Carpenter wrote:
> There are some missing error codes here so we accidentally return NULL
> instead of an error pointer.  It results in a NULL pointer dereference.
> 
> Fixes: df71837d5024 ("[LSM-IPSec]: Security association restriction.")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Patch applied, thanks!
