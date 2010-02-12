From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe RSS not working as expected with 8021q and bridging
Date: Fri, 12 Feb 2010 11:52:20 -0800 (PST)
Message-ID: <20100212.115220.206892220.davem@davemloft.net>
References: <20100210205048.GT20231@esk.cs.usu.edu>
	<20100212190340.GB20231@esk.cs.usu.edu>
	<1266004097.2939.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: esk-netdev@esk.cs.usu.edu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37004
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757093Ab0BLTwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 14:52:07 -0500
In-Reply-To: <1266004097.2939.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Feb 2010 20:48:17 +0100

> TX path is supposed to go through dev_pick_tx() & skb_tx_hash(), maybe
> bridging has a shortcut and need a fix, like we also do in pktgen (sorry
> I wont be able to check this before few days)

I just made a quick check and bridging seems lack any such shortcuts
and is a good citizen. :-)

It transmits packets using dev_queue_xmit().
