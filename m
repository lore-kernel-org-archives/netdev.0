From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when promiscuous mode
Date: Tue, 13 Nov 2007 19:09:23 +0800
Message-ID: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au>
References: <47397AB3.90705@trash.net>
Cc: joonwpark81@gmail.com, davem@davemloft.net, w@1wt.eu,
	cfriesen@nortel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: kaber@trash.net (Patrick McHardy)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1067 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752677AbXKMLLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:11:11 -0500
In-Reply-To: <47397AB3.90705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
>
> I still think promiscous mode should disable all filters (which would
> also provide a consistent view between accerlated and non-accerlated
> devices), but an ethtool option is better than nothing :)

I agree.  People doing a tcpdump don't have to turn on promiscuous
mode, that's what the -p option is for.  In other words, having
promiscuous mode disable VLAN filtering does not take away the
user's options at all.

In fact, the very definition of promiscuous is to turn off hardware
filtering, albeit the filtering of MAC addresses rather than VLAN
tags.  So it would seem logical to have it turn off VLAN filtering
too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
