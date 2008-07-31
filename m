From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 03:16:54 -0700 (PDT)
Message-ID: <20080731.031654.44296685.davem@davemloft.net>
References: <20080731023652.GA23814@xi.wantstofly.org>
	<20080731030339.GA4327@gondor.apana.org.au>
	<20080731101425.GE23814@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33898
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750937AbYGaKQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:16:54 -0400
In-Reply-To: <20080731101425.GE23814@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 31 Jul 2008 12:14:25 +0200

> As to the congestion window, I had the idea that it's not increasing
> beyond ~2-3 because the RTT is so low so it doesn't need much data
> to fill the pipe, but I'm not a TCP expert.

Local network 10GB needs a pretty decent congestion window.

Well, it needs to be at least as big as the largest amount of
non-retransmitted data in-flight, and you've stated here that
the receive has grown it's window to 700K.
