From: David Miller <davem@davemloft.net>
Subject: Re: tcp_shift_skb_data uses wrong mss in non-gso case?
Date: Wed, 25 Aug 2010 16:43:31 -0700 (PDT)
Message-ID: <20100825.164331.68143250.davem@davemloft.net>
References: <AANLkTi=ygaa_fV4SwaLY2gP9H+Nn54QdXcGXkfGukSCD@mail.gmail.com>
	<alpine.DEB.2.00.1008241008250.31124@melkinpaasi.cs.helsinki.fi>
	<D3B72A8DFCA0A8418CB61D1E9E310A99E5F35252@US01XMB01.org.nasdaqomx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, jesse.brandeburg@gmail.com,
	herbert@gondor.hengli.com.au, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: robert.evans@nasdaqomx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46962
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752751Ab0HYXnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:43:16 -0400
In-Reply-To: <D3B72A8DFCA0A8418CB61D1E9E310A99E5F35252@US01XMB01.org.nasdaqomx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Evans <robert.evans@nasdaqomx.com>
Date: Wed, 25 Aug 2010 10:43:23 -0400

> However, that code was added after Ilpo's SACK patches. The original patch 
> went in for 2.6.29, and Ilpo fixed the retransmit in 2.6.30.  So 2.6.29 and 
> its descendants can have this problem. I'm using 2.6.29.4, so there you 
> have it.
> 
> A kernel update will definitely fix my problem, so that should be the 
> end of it.  Thanks for your time everyone!

Thanks for hunting down the true cause of the problem.

If 2.6.29.x-stable was still active we should submit a backport but
to the best of my knowledge that branch -stable is no longer active.
