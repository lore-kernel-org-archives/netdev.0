From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Thu, 16 Apr 2009 02:02:52 -0700 (PDT)
Message-ID: <20090416.020252.74112364.davem@davemloft.net>
References: <49E64BE4.1050908@myri.com>
	<20090415.164248.188350673.davem@davemloft.net>
	<20090416085022.GA19731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, brice@myri.com, sgruszka@redhat.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36968
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751930AbZDPJDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:03:01 -0400
In-Reply-To: <20090416085022.GA19731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 16 Apr 2009 16:50:22 +0800

> On Wed, Apr 15, 2009 at 04:42:48PM -0700, David Miller wrote:
>> 
>> Herbert has been working on various optimizations to get
>> cxgb3 GRO performance on par with LRO.  Perhaps he has
>> some things for you to try :-)
> 
> Yes, this patch should improve performace.  In fact, when you
> reopen the net-next tree feel free to put this patch in :)
> 
> gro: New frags interface to avoid copying shinfo
> 
> It turns out that copying a 16-byte area at ~800k times a second
> can be really expensive :) This patch redesigns the frags GRO
> interface to avoid copying that area twice.
> 
> The two disciples of the frags interface have been converted.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

It is open already, so, applied :-)
