From: David Miller <davem@davemloft.net>
Subject: Re: passthrough openswan connection not working with 2.6.19.2
Date: Tue, 16 Jan 2007 19:05:46 -0800 (PST)
Message-ID: <20070116.190546.74731258.davem@davemloft.net>
References: <E1H6vOb-0005Nr-00@gondolin.me.apana.org.au>
	<20070116.170719.74742439.davem@davemloft.net>
	<20070117023501.GA23015@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, pupilla@hotmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751980AbXAQDFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 22:05:45 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <20070117023501.GA23015@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Jan 2007 13:35:01 +1100

> On Tue, Jan 16, 2007 at 05:07:19PM -0800, David Miller wrote:
> > 
> > Good catch Herbert, patch applied, thanks.
> 
> Thanks Dave.  I think we need this for 2.6.19 too.
> 
> [IPSEC]: Policy list disorder
> 
> The recent hashing introduced an off-by-one bug in policy list insertion.
> Instead of adding after the last entry with a lesser or equal priority,
> we're adding after the successor of that entry.
> 
> This patch fixes this and also adds a warning if we detect a duplicate
> entry in the policy list.  This should never happen due to this if clause.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Yep:

Signed-off-by: David S. Miller <davem@davemloft.net>
