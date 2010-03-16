From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Tue, 16 Mar 2010 14:13:11 -0700 (PDT)
Message-ID: <20100316.141311.262178287.davem@davemloft.net>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	<4B9FC7F1.5010507@google.com>
	<1268773227.2932.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53772
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751157Ab0CPVMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:12:49 -0400
In-Reply-To: <1268773227.2932.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Mar 2010 22:00:27 +0100

> Well, I tested this on my dev machine, with a vlan over bonding setup,
> tg3 and bnx2 drivers (mono queue), and all is good. UDP bench not
> anymore using 100% of one cpu and dropping frames.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Thanks Herbert, this gives a very good fanout of network load on cpus,
> this is a huge improvement, I cannot wait 2.6.35 :)

I'll integrate this as soon as I open up net-next-2.6
