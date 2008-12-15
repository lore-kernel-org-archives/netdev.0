From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host
 communication.
Date: Mon, 15 Dec 2008 14:29:18 -0800 (PST)
Message-ID: <20081215.142918.190909950.davem@davemloft.net>
References: <4946717F.2090809@codemonkey.ws>
	<20081215.114315.165733593.davem@davemloft.net>
	<4946C1AA.4080404@codemonkey.ws>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gleb@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: anthony@codemonkey.ws
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751712AbYLOW3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 17:29:16 -0500
In-Reply-To: <4946C1AA.4080404@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anthony Liguori <anthony@codemonkey.ws>
Date: Mon, 15 Dec 2008 14:44:26 -0600

> We want this communication mechanism to be simple and reliable as we
> want to implement the backends drivers in the host userspace with
> minimum mess.

One implication of your statement here is that TCP is unreliable.
That's absolutely not true.

> Within the guest, we need the interface to be always available and
> we need an addressing scheme that is hypervisor specific.  Yes, we
> can build this all on top of TCP/IP.  We could even build it on top
> of a serial port.  Both have their down-sides wrt reliability and
> complexity.

I don't know of any zero-copy through the hypervisor mechanisms for
serial ports, but I know we do that with the various virtualization
network devices.

> Do you have another recommendation?

I don't have to make alternative recommendations until you can
show that what we have can't solve the problem acceptably, and
TCP emphatically can.
