From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: Fix memory leak of aead algorithm name
Date: Mon, 19 Sep 2016 13:07:49 +0200
Message-ID: <20160919110749.GH31137@gauss.secunet.com>
References: <AM4PR0501MB19404B000E4D3A2CF3CB80DEDBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ilan Tayari <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50137 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750825AbcISLHy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 07:07:54 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB19404B000E4D3A2CF3CB80DEDBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2016 at 07:42:53AM +0000, Ilan Tayari wrote:
> commit 1a6509d99122 ("[IPSEC]: Add support for combined mode algorithms")
> introduced aead. The function attach_aead kmemdup()s the algorithm
> name during xfrm_state_construct().
> However this memory is never freed.
> Implementation has since been slightly modified in
> commit ee5c23176fcc ("xfrm: Clone states properly on migration")
> without resolving this leak.
> This patch adds a kfree() call for the aead algorithm name.
> 
> Fixes: 1a6509d99122 ("[IPSEC]: Add support for combined mode algorithms")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>

Applied to the ipsec tree, thanks Ilan!
