From: David Miller <davem@davemloft.net>
Subject: Re: Namespaces and inetpeer
Date: Mon, 12 Mar 2012 03:05:40 -0700 (PDT)
Message-ID: <20120312.030540.1898764639886137604.davem@davemloft.net>
References: <20120312085756.GL15404@secunet.com>
	<20120312.023505.2024370184180125281.davem@davemloft.net>
	<20120312095840.GM15404@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab2CLKFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 06:05:53 -0400
In-Reply-To: <20120312095840.GM15404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 12 Mar 2012 10:58:40 +0100

> On Mon, Mar 12, 2012 at 02:35:05AM -0700, David Miller wrote:
>> Then you will ask for one per security policy too, to handle IPSEC.
> 
> Hm, I don't see why this would be needed too.

Oh, that's right, we use independent kmalloc'd metrics for IPSEC
routes.

> It was just an idea to handle the metrcis with policy routing.

Right :-)
