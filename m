From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Tue, 16 Jun 2009 12:35:47 -0400
Message-ID: <20090616163547.GC5013@neterion.com>
References: <20090529162312.GA5191@neterion.com> <20090610054449.GB16984@gondor.apana.org.au> <20090612160926.GA4290@neterion.com> <20090612.164833.35888001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:59976 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760319AbZFPQfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 12:35:53 -0400
Content-Disposition: inline
In-Reply-To: <20090612.164833.35888001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2009 at 04:48:33PM -0700, David Miller wrote:
> I find a 500Mbps difference, due to just one single cache miss on
> every packet, simply astounding and unbelievable.  But hey, it is
> what you are seeing, so something has to account for it. :)

The cache miss only accounts for ~50Mbpsi, it'd be nice if there was an 
easy way to get the whole 500Mbps back.  The rest seems to be in the 
general overhead of the GRO code vs the normal NAPI rx path.  The P4 
Xeon is substantially worse at string operations than the Core 2 / Core i7 
based Xeons, so I'm hoping to test and see if they do any better with the 
GRO code when I get access to a new machine soon.

		-ben
