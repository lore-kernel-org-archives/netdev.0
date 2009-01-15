From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Wed, 14 Jan 2009 21:43:02 -0800 (PST)
Message-ID: <20090114.214302.04323798.davem@davemloft.net>
References: <20090114044856.GA14726@gondor.apana.org.au>
	<20090114.210242.163189105.davem@davemloft.net>
	<20090115050449.GA30174@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53772
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750874AbZAOFnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:43:01 -0500
In-Reply-To: <20090115050449.GA30174@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 15 Jan 2009 16:04:49 +1100

> On Wed, Jan 14, 2009 at 09:02:42PM -0800, David Miller wrote:
> >
> > Actually, we return EINVAL just a few lines above this code
> > block for some other socket option cases when optval==NULL.
> 
> Well the very next option IPV6_2292PKTOPTIONS returns EFAULT
> by virtue of not explicitly checking optval == NULL :)

Touche' :-)
