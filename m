From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix length computation in rt_check_expire()
Date: Tue, 19 May 2009 23:13:13 -0700 (PDT)
Message-ID: <20090519.231313.155860479.davem@davemloft.net>
References: <20090519192450.GF28034@hmsreliant.think-freely.org>
	<20090519.150517.62361946.davem@davemloft.net>
	<4A138CFE.5070901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, jarkao2@gmail.com, lav@yar.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35311
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751819AbZETGNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 02:13:15 -0400
In-Reply-To: <4A138CFE.5070901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 20 May 2009 06:54:22 +0200

> I would like to split patches because we have two bugs indeed, and
> I prefer to get attention for both problems, I dont remember Neil acknowledged
> the length computation problem.
> 
> First and small patch, candidate for net-2.6 and stable (for 2.6.29) :
> 
> Thank you
> 
> [PATCH] net: fix length computation in rt_check_expire()
> 
> rt_check_expire() computes average and standard deviation of chain lengths,
> but not correclty reset length to 0 at beginning of each chain.
> This probably gives overflows for sum2 (and sum) on loaded machines instead 
> of meaningful results.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Yes I definitely agree this length initialization is a bug.

I'll integrate this fix soon, thanks Eric.  You can send me the
other part of the bug fix relative to this if you like.
