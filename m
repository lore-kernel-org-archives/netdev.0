From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 0/4] net: Introduce protodown flag.
Date: Wed, 15 Jul 2015 21:40:01 -0700 (PDT)
Message-ID: <20150715.214001.1210964588957604209.davem@davemloft.net>
References: <1436906602-2958-1-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822AbbGPEkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:40:02 -0400
In-Reply-To: <1436906602-2958-1-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: anuradhak@cumulusnetworks.com
Date: Tue, 14 Jul 2015 13:43:18 -0700

> User space daemons can detect errors in the network that need to be
> notified to the switch device drivers.
> 
> Drivers can react to this error state by doing a phy-down on the
> switch-port which would result in a carrier-off locally and on the directly
> connected switch. Doing that would prevent loops and black-holes in the
> network.

Series applied, thanks.
