From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Add a XFRM_STATE_AF_UNSPEC flag to
 xfrm_usersa_info
Date: Thu, 10 Jul 2008 16:55:44 -0700 (PDT)
Message-ID: <20080710.165544.39072357.davem@davemloft.net>
References: <20080710112901.GV9549@secunet.com>
	<20080710123154.GA25589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755199AbYGJXzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 19:55:44 -0400
In-Reply-To: <20080710123154.GA25589@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 10 Jul 2008 20:31:54 +0800

> On Thu, Jul 10, 2008 at 01:29:01PM +0200, Steffen Klassert wrote:
> > Add a XFRM_STATE_AF_UNSPEC flag to handle the AF_UNSPEC behavior
> > for the selector family. Userspace applications can set this flag
> > to leave the selector family of the xfrm_state unspecified.
> > This can be used to to handle inter family tunnels if the
> > selector is not set from userspace.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
