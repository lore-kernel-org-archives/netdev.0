From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/24] [IPSEC]: Make sure idev is consistent with dev in
 xfrm_dst
Date: Tue, 13 Nov 2007 21:36:22 -0800 (PST)
Message-ID: <20071113.213622.169351284.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZw-0001Gx-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37452
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751399AbXKNFgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:36:23 -0500
In-Reply-To: <E1IplZw-0001Gx-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:24 +0800

> [IPSEC]: Make sure idev is consistent with dev in xfrm_dst
> 
> Previously we took the device from the bottom route and idev from the top
> route.  This is bad because idev may well point to a different device.
> This patch changes it so that we get the idev from the device directly.
> 
> It also makes it an error if either dev or idev is NULL.  This is consistent
> with the rest of the routing code which also treats these cases as errors.
> 
> I've removed the err initialisation in xfrm6_policy.c because it achieves
> no purpose and hid a bug when an initial version of this patch neglected
> to set err to -ENODEV (fortunately the IPv4 version warned about it).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
