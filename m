From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 15:17:33 -0700 (PDT)
Message-ID: <20080724.151733.215864673.davem@davemloft.net>
References: <200807250049.46939.opurdila@ixiacom.com>
	<20080724.145600.30988015.davem@davemloft.net>
	<200807250112.03379.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42152
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751287AbYGXWRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 18:17:33 -0400
In-Reply-To: <200807250112.03379.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Fri, 25 Jul 2008 01:12:03 +0300

> On Friday 25 July 2008, David Miller wrote:
> 
> > We have a timestamp in the SKB already, why don't you simply override
> > it when your feature is enable and set a single flag bit that
> > indicates you used a HW timestamp to set that timestamp?
> 
> I thought of something similar, but I am not sure if I can to so, as it seems 
> that the skb->tstamp requires current gettimeofday semantics at least in 
> netfilter's ipt_time module.

Can your timestamp format at least be converted to
gettimeofday() format?

I thought we had a ton of accessor functions that code uses to access
the timestamp?  You should be able to do your translation in those
routines.
