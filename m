From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: fix GRO for !CONFIG_NETFILTER
Date: Thu, 27 Apr 2017 13:04:38 +0200
Message-ID: <20170427110438.GF2649@secunet.com>
References: <f04ee7d4593b4eaf3f7fe19fddbf111da81261c7.1493287089.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:60600 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968509AbdD0LHK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 07:07:10 -0400
Content-Disposition: inline
In-Reply-To: <f04ee7d4593b4eaf3f7fe19fddbf111da81261c7.1493287089.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 12:03:37PM +0200, Sabrina Dubroca wrote:
> In xfrm_input() when called from GRO, async == 0, and we end up
> skipping the processing in xfrm4_transport_finish(). GRO path will
> always skip the NF_HOOK, so we don't need the special-case for
> !NETFILTER during GRO processing.
> 
> Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks a lot Sabrina!
