From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix GRO for multiple page fragments
Date: Mon, 20 Apr 2009 02:24:03 -0700 (PDT)
Message-ID: <20090420.022403.194348592.davem@davemloft.net>
References: <20090417091433.GA1535@gondor.apana.org.au>
	<1239977010.5297.19.camel@deadeye.i.decadent.org.uk>
	<20090417144812.GC4182@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33602
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751086AbZDTJYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:24:11 -0400
In-Reply-To: <20090417144812.GC4182@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 17 Apr 2009 22:48:12 +0800

> On Fri, Apr 17, 2009 at 03:03:30PM +0100, Ben Hutchings wrote:
>>
>> The loop is iterating forward, not backward, so why initialise frag to
>> point to the last fragment?
> 
> Ah yes, that's completely bogus.  I suppose it only works because
> the current users only supply one frag under normal circumstanses.
> 
> Yes we should integrate your patch for 2.6.30.  For net-next the
> loop no longer exists so it should be fine.

I've applied Ben's patch.
