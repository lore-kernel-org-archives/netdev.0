From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Wed, 21 Nov 2012 23:39:45 -0500 (EST)
Message-ID: <20121121.233945.2225341904551631404.davem@davemloft.net>
References: <50AD1972.5080403@pobox.com>
	<1353529639.26346.164.camel@shinybook.infradead.org>
	<50ADA05B.2000308@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, jasowang@redhat.com, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982Ab2KVTZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 14:25:31 -0500
In-Reply-To: <50ADA05B.2000308@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Wed, 21 Nov 2012 22:47:39 -0500

> State A:  pre-b01af457, known working
> State B:  b01af457, known broken

State A is also known buggy on the largest consumer of this driver,
the emulated hardware.

Please evaluate this realistically.
