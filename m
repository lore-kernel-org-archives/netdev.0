From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Do not register ne2k-pci device until initialized
Date: Sat, 02 May 2009 13:52:39 -0700 (PDT)
Message-ID: <20090502.135239.20953799.davem@davemloft.net>
References: <49FC7D5E.6050203@garzik.org>
	<20090502175811.GA26635@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, lkundrak@v3.sk, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751527AbZEBUwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 16:52:44 -0400
In-Reply-To: <20090502175811.GA26635@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andi@lisas.de>
Date: Sat, 2 May 2009 19:58:11 +0200

> And, well...:
> 
> smsc911x.c looks like it has the same issue (in case of a non-specified
> MAC address - invalid EEPROM content).
> 
> Dito ucc_geth.c
> 
> Dito arm/ixp4xx_eth.c
> 
> Dito wireless/netwave_cs.c
> 
> Given that several drivers seem to violate this rule: is there a way
> to add a check against this problem?

I'm pretty sure we have a valid ethernet address check
somewhere already... hmmm..
