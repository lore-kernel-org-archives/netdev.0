From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] xfrm: avoid possible oopse in xfrm_alloc_dst
Date: Thu, 10 Feb 2011 23:08:56 -0800 (PST)
Message-ID: <20110210.230856.39171624.davem@davemloft.net>
References: <1297406495.18018.76.camel@vega>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timo.teras@iki.fi,
	herbert@gondor.apana.org.au
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753939Ab1BKHIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 02:08:20 -0500
In-Reply-To: <1297406495.18018.76.camel@vega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Fri, 11 Feb 2011 15:41:35 +0900

> Commit 80c802f3073e84 (xfrm: cache bundles instead of policies for
> outgoing flows) introduced possible oopse when dst_alloc returns NULL.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Good catch, applied.
