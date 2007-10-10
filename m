From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] Defer IPv6 device initialization until a valid
 qdisc is specified
Date: Wed, 10 Oct 2007 02:53:07 -0700 (PDT)
Message-ID: <20071010.025307.68156581.davem@davemloft.net>
References: <20071009162158.f25d4fdb.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	herbert@gondor.apana.org.au
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58864
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754154AbXJJJxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:53:05 -0400
In-Reply-To: <20071009162158.f25d4fdb.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Tue, 9 Oct 2007 16:21:58 +0900

> To judge the timing for DAD, netif_carrier_ok() is used. However,
> there is a possibility that dev->qdisc stays noop_qdisc even if
> netif_carrier_ok() returns true. In that case, DAD NS is not sent out.
> We need to defer the IPv6 device initialization until a valid qdisc
> is specified.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Thanks for submitting the fix.

Although Herbert is right that this does not fix the problem
universally, it does make things better, so I will apply this
patch.

Thanks!
