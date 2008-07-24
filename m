From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Fri, 25 Jul 2008 01:12:03 +0300
Message-ID: <200807250112.03379.opurdila@ixiacom.com>
References: <200807241922.57361.opurdila@ixiacom.com> <200807250049.46939.opurdila@ixiacom.com> <20080724.145600.30988015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2680 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751716AbYGXWOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 18:14:31 -0400
In-Reply-To: <20080724.145600.30988015.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 July 2008, David Miller wrote:

> Traversing the list and maintaining the reference counting and sharing
> issues is expensive and error prone.

I've notice that :) 

> We have a timestamp in the SKB already, why don't you simply override
> it when your feature is enable and set a single flag bit that
> indicates you used a HW timestamp to set that timestamp?

I thought of something similar, but I am not sure if I can to so, as it seems 
that the skb->tstamp requires current gettimeofday semantics at least in 
netfilter's ipt_time module.

Thanks,
tavi
