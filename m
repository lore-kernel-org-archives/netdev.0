From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Tue, 16 Feb 2010 15:14:34 -0800 (PST)
Message-ID: <20100216.151434.179169672.davem@davemloft.net>
References: <20100215081052.GA18516@gondor.apana.org.au>
	<20100215172810.GC4905@x200>
	<20100216052430.GA27643@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933495Ab0BPXOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:14:18 -0500
In-Reply-To: <20100216052430.GA27643@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 16 Feb 2010 13:24:30 +0800

> On Mon, Feb 15, 2010 at 07:28:10PM +0200, Alexey Dobriyan wrote:
>>
>> OK, it survives beating here.
> 
> Thanks a lot for testing! I'll do the clean-up you suggested in
> another patch.  Let's get this fixed first.
> 
> ipcomp: Avoid duplicate calls to ipcomp_destroy
> 
> When ipcomp_tunnel_attach fails we will call ipcomp_destroy twice.
> This may lead to double-frees on certain structures.
> 
> As there is no reason to explicitly call ipcomp_destroy, this patch
> removes it from ipcomp*.c and lets the standard xfrm_state destruction
> take place.
> 
> This is based on the discovery and patch by Alexey Dobriyan.
> 
> Tested-by: Alexey Dobriyan <adobriyan@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6
