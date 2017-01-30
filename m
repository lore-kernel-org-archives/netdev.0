From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next 2/2] xfrm: Add a dummy network device for
 napi.
Date: Mon, 30 Jan 2017 12:45:30 +0100
Message-ID: <20170130114530.GT30338@gauss.secunet.com>
References: <1485501572-20908-1-git-send-email-steffen.klassert@secunet.com>
 <1485501572-20908-3-git-send-email-steffen.klassert@secunet.com>
 <1485528398.6360.39.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170127.095349.597744818419458840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
        <sowmini.varadhan@oracle.com>, <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36892 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753403AbdA3Lzw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 06:55:52 -0500
Content-Disposition: inline
In-Reply-To: <20170127.095349.597744818419458840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 09:53:49AM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 27 Jan 2017 06:46:38 -0800
> 
> > On Fri, 2017-01-27 at 08:19 +0100, Steffen Klassert wrote:
> >> This patch adds a dummy network device so that we can
> >> use gro_cells for IPsec GRO. With this, we handle IPsec
> >> GRO with no impact on the generic networking code.
> >> 
> >> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> >> ---
> >>  net/xfrm/xfrm_input.c | 12 +++++++++++-
> >>  1 file changed, 11 insertions(+), 1 deletion(-)
> > 
> > That is nice ;)
> 
> I like it too.

I've applied both to ipsec-next, thanks for all the feedback!
