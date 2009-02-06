From: David Miller <davem@davemloft.net>
Subject: Re: gro: Fix frag_list merging on imprecisely split packets
Date: Thu, 05 Feb 2009 21:27:08 -0800 (PST)
Message-ID: <20090205.212708.166167413.davem@davemloft.net>
References: <20090206035728.GA4227@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	emil.s.tantilov@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751183AbZBFF1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 00:27:15 -0500
In-Reply-To: <20090206035728.GA4227@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 6 Feb 2009 14:57:28 +1100

> gro: Fix frag_list merging on imprecisely split packets
> 
> The previous fix ad0f9904444de1309dedd2b9e365cae8af77d9b1 (gro:
> Fix handling of imprecisely split packets) only fixed the case
> of frags merging, frag_list merging in the same circumstances
> were still broken.
> 
> In particular, the packet headers end up in the data stream.
> 
> This patch fixes this plus another issue where an imprecisely
> split packet header may be read incorrectly (this is mostly
> harmless since it'll simply cause the packet to not match and
> be rejected for GRO).
> 
> Thanks to Emil Tantilov and Jeff Kirsher for helping to track
> this down.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot for tracking this down.
