From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] xfrm: Accept XFRM_STATE_AF_UNSPEC SAs on IPv4/IPv6
 only hosts
Date: Wed, 03 Dec 2008 15:38:49 -0800 (PST)
Message-ID: <20081203.153849.98369998.davem@davemloft.net>
References: <1227629406.21037.193.camel@martin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: martin@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46404
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755055AbYLCXis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 18:38:48 -0500
In-Reply-To: <1227629406.21037.193.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Willi <martin@strongswan.org>
Date: Tue, 25 Nov 2008 17:10:06 +0100

> Installing SAs using the XFRM_STATE_AF_UNSPEC fails on hosts with
> support for one address family only. This patch accepts such SAs, even
> if the processing of not supported packets will fail.
> 
> Signed-off-by: Martin Willi <martin@strongswan.org>
> 
> ---
> For me the meaning of that flag is not really clear. If it means
> "I-want-to-run-v6-in-v4-or-vice-versa" then the current behavior
> (reject SA) is probably ok.
> However, in my understanding ("accept-any-inner-address-family"), the
> kernel should accept such SAs. Otherwise userspace has to query the
> supported address families.

Ok, your interpretation works for me, I've applied this to
net-next-2.6, thanks.
