From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 18:56:32 -0700 (PDT)
Message-ID: <20070725.185632.116383625.davem@davemloft.net>
References: <20070725.013154.34764933.davem@davemloft.net>
	<20070725095654.38a10abc@oldman.hamilton.local>
	<46A7FEFC.4040005@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59966
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754195AbXGZB4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 21:56:33 -0400
In-Reply-To: <46A7FEFC.4040005@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Wed, 25 Jul 2007 21:55:08 -0400

> I don't see any logic to your request, only added overhead for no reason.

There may be some flawed logic in what Stephen stated, but
the change really is needed.

It must be atomic to execute the:

	enable_interrupts();
	netif_rx_complete();

sequence wrt. the same code path in the interrupt handler.
