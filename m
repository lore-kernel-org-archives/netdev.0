From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Fix rx counters update in
 macvlan_handle_frame()
Date: Fri, 23 Jul 2010 00:31:41 -0700 (PDT)
Message-ID: <20100723.003141.174074877.davem@davemloft.net>
References: <1279839867.3274.25.camel@w-sridhar.beaverton.ibm.com>
	<20100723072338.GA4267@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877Ab0GWHbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 03:31:24 -0400
In-Reply-To: <20100723072338.GA4267@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 23 Jul 2010 15:23:39 +0800

> I don't think we should count packet drops when the interface is
> down.  This would be inconsistent with other devices such as
> IPIP.

Agreed.
