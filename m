From: David Miller <davem@davemloft.net>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Tue, 26 Feb 2008 23:23:14 -0800 (PST)
Message-ID: <20080226.232314.130964666.davem@davemloft.net>
References: <20080226.182120.183405235.davem@davemloft.net>
	<20080227072041.GA4000@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41506
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750743AbYB0HXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 02:23:14 -0500
In-Reply-To: <20080227072041.GA4000@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 27 Feb 2008 07:20:41 +0000

> I wonder why overloading with net processing is no concern here?
> There would be no napi control around this  netif_receive_skb().

Good point, but we're talking about loopback wherein only
the local system can overload itself.

> Another concern might be a code which depends on softirq context
> here (unless it was checked already)?

Hmmm.... yes this could be a problem.
