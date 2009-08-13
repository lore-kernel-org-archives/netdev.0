From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] be2net: fix bad queue traversal in
 be_rx_q_clean()
Date: Wed, 12 Aug 2009 22:16:41 -0700 (PDT)
Message-ID: <20090812.221641.97392835.davem@davemloft.net>
References: <20090810134323.GA10857@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753140AbZHMFQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 01:16:31 -0400
In-Reply-To: <20090810134323.GA10857@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 10 Aug 2009 19:13:23 +0530

> Using "for(tail != head)" to traverse a queue from tail to head
> fails in the case of a fully filled queue. Use "for(used != 0)" instead.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
