From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: '< 0' test on unsigned
Date: Fri, 13 Mar 2009 16:05:33 -0700 (PDT)
Message-ID: <20090313.160533.111575830.davem@davemloft.net>
References: <20090302043056.GA16090@gondor.apana.org.au>
	<20090301.203643.105143832.davem@davemloft.net>
	<49ABD014.3010006@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48213
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751588AbZCMXFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 19:05:47 -0400
In-Reply-To: <49ABD014.3010006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 02 Mar 2009 13:24:52 +0100

> David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Mon, 2 Mar 2009 12:30:56 +0800
> > 
> >> Either cnt needs to be promoted, or you need to limit len to INT_MAX.
> > 
> > Right, since the positive range of 'size_t' can exceed that of 'int'
> 
> like this then?
> ------------------------------>8-------------8<---------------------------------
> promote 'cnt' to size_t, to match 'len'.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks.
