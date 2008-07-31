From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 05:35:16 -0700 (PDT)
Message-ID: <20080731.053516.185810642.davem@davemloft.net>
References: <20080731101425.GE23814@xi.wantstofly.org>
	<20080731.031654.44296685.davem@davemloft.net>
	<20080731122541.GA29176@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org, dale@farnsworth.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750828AbYGaMfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 08:35:16 -0400
In-Reply-To: <20080731122541.GA29176@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 31 Jul 2008 14:25:41 +0200

> At this point things seem to be CPU limited at the sender again.  E.g.
> by simply dropping IRQF_SAMPLE_RANDOM from mv643xx_eth.c (the driver
> used on the sender), throughput jumps to ~108 MiB/s, and I get:
 ...
> Putting the 5 * mss_now nagle hack back in doesn't seem to change
> the gso_size distribution anymore at this point, and it doesn't
> change the numbers much:
 ...
> The throughput with software GSO off again seems to be about ~93 MiB/s:

So I would conclude that at the moment we should just do the software
GSO enabling thing (with the recent suggestions made by Herbert) and
for the time being the nagle hack isn't something to consider closely.
