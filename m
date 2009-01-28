From: David Miller <davem@davemloft.net>
Subject: Re: Question on netif_tx_queue_stopped
Date: Tue, 27 Jan 2009 22:10:43 -0800 (PST)
Message-ID: <20090127.221043.244908230.davem@davemloft.net>
References: <497FF58D.50601@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751717AbZA1GKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 01:10:46 -0500
In-Reply-To: <497FF58D.50601@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 27 Jan 2009 22:05:01 -0800

> I'm doing some tests with pktgen and the 8139too (realtek) driver
> in kernel 2.6.29-rc2.
> 
> It seems that netif_tx_queue_stopped will return false fairly often even if the
> cable is pulled from the NIC.
> 
> Is that expected?

Yep.

Pulling the cable out only effects netif_carrier_ok().
