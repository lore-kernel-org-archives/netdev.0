From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec 0/3] vti/vti6: minor tweaks + one fix
Date: Tue, 13 May 2014 10:41:14 +0200
Message-ID: <20140513084114.GZ32371@secunet.com>
References: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36351 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031AbaEMIlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 04:41:24 -0400
Content-Disposition: inline
In-Reply-To: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 09, 2014 at 11:43:39PM +0200, Mathias Krause wrote:
> Hi Steffen,
> 
> this series addresses a few issues related to VTI. The first patch fixes
> a bug in the vti6 module calling unregister_pernet_device() twice in the
> error path. That's probably material for ipsec.git.
> The second patch simplifies the error handling path in module init/fini
> of vti6. The third patch does the same for vti. Those two are probably
> material for ipsec-next.git as we're at -rc5 already. But I leave that
> decision to you.

Right, patches two and three should go to ipsec-next. But the second
patch does not apply without the first patch. Please send separate
patchsets for ipsec and ipsec-next in future.

Thanks!
