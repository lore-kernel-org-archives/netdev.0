From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: Use bitmask of feature flags instead of seperate
 feature bits
Date: Fri, 23 May 2008 00:30:51 -0700 (PDT)
Message-ID: <20080523.003051.153798887.davem@davemloft.net>
References: <48366C0F.4020905@trash.net>
	<20080523070945.GB6615@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751901AbYEWHaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 03:30:55 -0400
In-Reply-To: <20080523070945.GB6615@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 23 May 2008 17:09:45 +1000

> On Fri, May 23, 2008 at 09:02:39AM +0200, Patrick McHardy wrote:
> > 
> >     [VLAN]: Use bitmask of feature flags instead of seperate feature bits
> >     
> >     Herbert Xu points out that the use of seperate feature bits for features
> >     to be propagated to VLAN devices is going to get messy real soon.
> >     Replace the VLAN feature bits by a bitmask of feature flags to be
> >     propagated and restore the old GSO_SHIFT/MASK values.
> >     
> >     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Looks great Patrick, thanks!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and pushed out to net-2.6, thanks everyone!
