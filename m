From: Andi Kleen <andi@firstfloor.org>
Subject: Re: OFT - reserving CPU's for networking
Date: Sat, 1 May 2010 12:53:04 +0200
Message-ID: <20100501105304.GA9434@gargoyle.fritz.box>
References: <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain> <20100430.115715.216750975.davem@davemloft.net> <20100430210131.GA2833@gargoyle.fritz.box> <20100430.153038.62351857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48734 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab0EAKue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 06:50:34 -0400
Content-Disposition: inline
In-Reply-To: <20100430.153038.62351857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> And we don't want it to, because the decision mechanisms for steering
> that we using now are starting to get into the stateful territory and
> that's verbotton for NIC offload as far as we're concerned.

Huh? I thought full TCP offload was forbidden?[1] Statefull as in NIC 
(or someone else like netfilter) tracking flows is quite common and very far 
from full offload. AFAIK it doesn't have near all the problems full
offload has.

-Andi

[1] although it seems to leak in more and more through the RDMA backdoor.
