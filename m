From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: NULL dereference on allocation failure
Date: Thu, 15 Jun 2017 13:57:40 +0200
Message-ID: <20170615115740.GH2631@secunet.com>
References: <20170614103537.GJ29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trent Jaeger <tjaeger@cse.psu.edu>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46062 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752387AbdFOL5n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 07:57:43 -0400
Content-Disposition: inline
In-Reply-To: <20170614103537.GJ29394@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 01:35:37PM +0300, Dan Carpenter wrote:
> The default error code in pfkey_msg2xfrm_state() is -ENOBUFS.  We
> added a new call to security_xfrm_state_alloc() which sets "err" to zero
> so there several places where we can return ERR_PTR(0) if kmalloc()
> fails.  The caller is expecting error pointers so it leads to a NULL
> dereference.
> 
> Fixes: df71837d5024 ("[LSM-IPSec]: Security association restriction.")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Also applied, thanks a lot Dan!
