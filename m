From: David Miller <davem@davemloft.net>
Subject: Re: poll broken (for can)
Date: Wed, 30 Mar 2011 00:05:18 -0700 (PDT)
Message-ID: <20110330.000518.242131416.davem@davemloft.net>
References: <4D90CB17.4030205@hartkopp.net>
	<4D90E262.1090201@pengutronix.de>
	<4D923B00.20500@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, wg@grandegger.com,
	socketcan-users@lists.berlios.de, netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52144
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751459Ab1C3HF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 03:05:57 -0400
In-Reply-To: <4D923B00.20500@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 29 Mar 2011 22:03:12 +0200

> Hm - the problem could be that people expect their frames to be sent 'in
> time', so if we increase the tx_queue_len, it's not transparent when the
> frames are potentially leaving the system - and if the application data is
> already out-dated when hitting the medium.
> 
> What about having up to three CAN frames in each CAN_RAW socket send buffer
> and e.g.50 frames in the tx_queue_len of the netdevice as a starting point?

Setting tx_queue_len low is bound to cause all kinds of problems.

This poll() peculiarity is just one such problem.

I would suggest increasing it for CAN devices to at least 100.
