From: David Miller <davem@davemloft.net>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Fri, 12 Jun 2009 16:48:33 -0700 (PDT)
Message-ID: <20090612.164833.35888001.davem@davemloft.net>
References: <20090529162312.GA5191@neterion.com>
	<20090610054449.GB16984@gondor.apana.org.au>
	<20090612160926.GA4290@neterion.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ben.lahaise@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55376
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750709AbZFLXsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 19:48:31 -0400
In-Reply-To: <20090612160926.GA4290@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <ben.lahaise@neterion.com>
Date: Fri, 12 Jun 2009 12:09:26 -0400

> I found at least one reason why: the first skb_shinfo()->frag_list touch 
> in dev_gro_receive() was causing a cache miss.  Adding a prefetch in the 
> driver helps that a little bit, but there's still > 500Mbps difference.  

I find a 500Mbps difference, due to just one single cache miss on
every packet, simply astounding and unbelievable.  But hey, it is
what you are seeing, so something has to account for it. :)
