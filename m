From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 1/2] xfrm6: Fix IPv6 payload_len in
 xfrm6_transport_finish
Date: Thu, 22 Jun 2017 09:15:50 +0200
Message-ID: <20170622071550.GT2631@secunet.com>
References: <1497861201-30262-1-git-send-email-yossiku@mellanox.com>
 <20170621053725.GP2631@secunet.com>
 <AM4PR0501MB22743B34120802DA21BCE59BC4DA0@AM4PR0501MB2274.eurprd05.prod.outlook.com>
 <20170621113806.GR2631@secunet.com>
 <AM4PR0501MB227460BDE5F2C9A370E13B80C4DA0@AM4PR0501MB2274.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Yossi Kuperman <yossiku@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41038 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751130AbdFVHPx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 03:15:53 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB227460BDE5F2C9A370E13B80C4DA0@AM4PR0501MB2274.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 08:38:13PM +0000, Yossi Kuperman wrote:
> 
> The bug is there nonetheless, it just doesn't seem to affect anything.
> I guess no one was looking inside the IP header thereafter.  
> 
> Should I use this instead: 7785bba299a8 ("esp: Add a software GRO codepath")?

Yes, please do this. The Fixes tag tells which stable kernels need
this patch. If we did not have problems before we added GRO, then
there is no need to backport it any further.

Thanks!
