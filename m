From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 22:00:31 -0400
Message-ID: <46A8003F.1050208@garzik.org>
References: <20070725.013154.34764933.davem@davemloft.net> <20070725095654.38a10abc@oldman.hamilton.local> <46A7FEFC.4040005@pobox.com> <20070725.185632.116383625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43274 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618AbXGZCAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 22:00:34 -0400
In-Reply-To: <20070725.185632.116383625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Wed, 25 Jul 2007 21:55:08 -0400
> 
>> I don't see any logic to your request, only added overhead for no reason.
> 
> There may be some flawed logic in what Stephen stated, but
> the change really is needed.
> 
> It must be atomic to execute the:
> 
> 	enable_interrupts();
> 	netif_rx_complete();
> 
> sequence wrt. the same code path in the interrupt handler.

Sure.  And how did the existing code fail to achieve that?

	Jeff



