From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm_user: propagate sec ctx allocation errors
Date: Fri, 9 Sep 2016 10:34:56 +0200
Message-ID: <20160909083456.GZ31137@gauss.secunet.com>
References: <1473350997-32733-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59992 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752957AbcIIIfC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 04:35:02 -0400
Content-Disposition: inline
In-Reply-To: <1473350997-32733-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 06:09:57PM +0200, Mathias Krause wrote:
> When we fail to attach the security context in xfrm_state_construct()
> we'll return 0 as error value which, in turn, will wrongly claim success
> to userland when, in fact, we won't be adding / updating the XFRM state.
> 
> This is a regression introduced by commit fd21150a0fe1 ("[XFRM] netlink:
> Inline attach_encap_tmpl(), attach_sec_ctx(), and attach_one_addr()").
> 
> Fix it by propagating the error returned by security_xfrm_state_alloc()
> in this case.
> 
> Fixes: fd21150a0fe1 ("[XFRM] netlink: Inline attach_encap_tmpl()...")
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied to the ipsec tree, thanks Mathias!
