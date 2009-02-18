From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Simplify skb_tx_hash()
Date: Tue, 17 Feb 2009 22:53:55 -0800 (PST)
Message-ID: <20090217.225355.184526778.davem@davemloft.net>
References: <20090218053211.16619.33544.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50110
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751773AbZBRGyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 01:54:11 -0500
In-Reply-To: <20090218053211.16619.33544.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 18 Feb 2009 11:02:11 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> The initialization of skb_tx_hashrnd is moved so that it gets called
> after "random" driver is initialized. Random numbers generated at this
> point are different across 3 immediate reboots:
> 	(reboot1) Random number: 0xd52f08b6
> 	(reboot2) Random number: 0x8beeef46
> 	(reboot3) Random number: 0x7d60a4b6
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Well, two questions:

1) How in the world are you getting a packet transmitted
   before the random driver initializes?

2) How can an initcall be more random than when the first
   packet is transmitted by the system?

A patch like this needs justification, so in your commit
logs you shouldn't just list out mechanically what your
patch is doing, but rather explain "why".
