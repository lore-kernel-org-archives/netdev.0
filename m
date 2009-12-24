From: David Miller <davem@davemloft.net>
Subject: Re: gianfar select_queue bogosity
Date: Wed, 23 Dec 2009 22:29:38 -0800 (PST)
Message-ID: <20091223.222938.241429611.davem@davemloft.net>
References: <OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com>
	<20091223.211157.68124463.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81BA0904E@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, yinghai@kernel.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, avorontsov@ru.mvista.com,
	galak@kernel.crashing.org
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751341AbZLXG3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 01:29:37 -0500
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA0904E@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Thu, 24 Dec 2009 11:34:23 +0530

> What if I want to maintaing a 1-1 mapping b/w the Rx/Tx queues.
> For eg., I want a packet received on queue-1 on eth0 to be forwarded on
> to queue-1 on eth1.

That's what the default code does when forwarding/bridging!

And for locally generated packets it uses the flow hash.

What do you think we do by default?  Go read the code :-)

