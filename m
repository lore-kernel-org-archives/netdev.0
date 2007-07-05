From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][IPV6] addrconf: fix timer deleting on exit
Date: Thu, 05 Jul 2007 14:37:40 -0700 (PDT)
Message-ID: <20070705.143740.45154350.davem@davemloft.net>
References: <20070705111246.GB1569@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	herbert@gondor.apana.org.au
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757909AbXGEVhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 17:37:21 -0400
In-Reply-To: <20070705111246.GB1569@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Thu, 5 Jul 2007 13:12:46 +0200

> 
> It looks like a timer function can be running and rearm
> the timer after removing a ipv6 module.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

This is completely academic as ipv6 as a module cannot
be removed, and it's been that way for years :-)
