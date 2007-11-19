From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Mon, 19 Nov 2007 00:32:54 -0800 (PST)
Message-ID: <20071119.003254.41095932.davem@davemloft.net>
References: <20071118214515.GA8161@one.firstfloor.org>
	<20071118.144010.236028466.davem@davemloft.net>
	<20071119044117.GA1880@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34030
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751792AbXKSIcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 03:32:55 -0500
In-Reply-To: <20071119044117.GA1880@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 19 Nov 2007 12:41:17 +0800

> On Sun, Nov 18, 2007 at 02:40:10PM -0800, David Miller wrote:
> >
> > This can be fixed, the above cannot.
> 
> That's a good point.  Perhaps one way of getting that info to
> the user without putting it in UDPInDatagrams is to create an
> inet_diag interface for UDP and put the number of queued packets
> for each socket in it.

Right, if it's not what the RFC specifies, it's an auxiliary
statistic we can provide some other way.
