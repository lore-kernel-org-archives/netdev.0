From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc35815: Remove a wrong netif_wake_queue() call which
 triggers BUG_ON
Date: Tue, 23 Feb 2010 01:26:14 -0800 (PST)
Message-ID: <20100223.012614.109539080.davem@davemloft.net>
References: <1266592438-10772-1-git-send-email-anemo@mba.ocn.ne.jp>
	<20100220.003122.26280041.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56530
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751665Ab0BWJZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 04:25:57 -0500
In-Reply-To: <20100220.003122.26280041.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Sat, 20 Feb 2010 00:31:22 +0900 (JST)

> On Sat, 20 Feb 2010 00:13:58 +0900, Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
>> @@ -1437,7 +1437,6 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
>>  		/* Transmit complete. */
>>  		lp->lstats.tx_ints++;
>>  		tc35815_txdone(dev);
>> -		netif_wake_queue(dev);
>>  		if (ret < 0)
>>  			ret = 0;
>>  	}
> 
> BTY, it looks isa-skelton.c have same problem.
 ...
> I suppose here is the far origin of the bug :)

Please send a patch for this.

Thank you.
