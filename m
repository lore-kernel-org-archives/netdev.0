From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] be2net: clear & notify residual
 events before destroying event queues
Date: Wed, 12 Aug 2009 22:16:46 -0700 (PDT)
Message-ID: <20090812.221646.95789316.davem@davemloft.net>
References: <20090810134351.GA10874@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47608
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753141AbZHMFQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 01:16:35 -0400
In-Reply-To: <20090810134351.GA10874@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 10 Aug 2009 19:13:51 +0530

> Any events rcvd after interrupts are disabled (in the driver unload path),
> must be cleared and notified before the event queues are destroyed
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
