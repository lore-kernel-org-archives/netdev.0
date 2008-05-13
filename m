From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/T] [NET] make pskb_expand_head warn when called with
 invalid state
Date: Tue, 13 May 2008 01:38:02 -0700 (PDT)
Message-ID: <20080513.013802.63822319.davem@davemloft.net>
References: <1210003274.8245.35.camel@johannes.berg>
	<20080512.221513.178144312.davem@davemloft.net>
	<1210667528.3646.28.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758513AbYEMIiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 04:38:08 -0400
In-Reply-To: <1210667528.3646.28.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 13 May 2008 10:32:08 +0200

> > FWIW, the only practical case where this can occur is for an SG+CSUM
> > device which cannot handle DMA'ing highmem pages, and we get such a
> > page via sendfile() or similar.
> 
> That's well possible since I'm using sungem and it says "no highdma" but
> "sg/hwcsum" for my hardware, and I do have highmem.

It appears only some sungem parts support full 64-bit DMA, so
yes that's indeed possible.


