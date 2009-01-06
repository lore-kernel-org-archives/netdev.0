From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] gro: Add internal interfaces for VLAN
Date: Tue, 06 Jan 2009 10:49:46 -0800 (PST)
Message-ID: <20090106.104946.194471167.davem@davemloft.net>
References: <20090105094730.GA15756@gondor.apana.org.au>
	<20090105095131.GA15851@gondor.apana.org.au>
	<20090106071142.GA27281@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43191
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755508AbZAFSto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 13:49:44 -0500
In-Reply-To: <20090106071142.GA27281@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 6 Jan 2009 18:11:42 +1100

> gro: Add internal interfaces for VLAN
> 
> Previously GRO's only entry point from the outside is through
> napi_gro_receive and napi_gro_frags.  These interfaces are for
> device drivers.
> 
> This patch rearranges things to provide a new set of interfaces
> for VLANs.  These interfaces are for internal use only.  The
> VLAN code itself can then provide a set of entry points for
> device drivers.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
