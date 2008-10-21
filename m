From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 15:04:36 +0200
Message-ID: <18685.54116.517096.363575@robur.slu.se>
References: <20081020190922.7dd6510a@extreme>
	<48FD6E8A.6060304@cosmosbay.com>
	<18685.37380.34636.316536@robur.slu.se>
	<48FD97AB.1040007@baidu.com>
	<18685.51303.285228.177350@robur.slu.se>
	<48FDCE3D.9050801@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Terry <hanfang@baidu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:49220 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965AbYJUNEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 09:04:37 -0400
In-Reply-To: <48FDCE3D.9050801@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:

 > I suspect all this skb recycling stuff in forwarding workloads is defeated anyway...
 > 
 > By the copybreak feature... (RX_COPY_THRESHOLD = 256 for example on tg3)


 Right. I use to turn it off as forwarding is the major application. I'll remember 
 it was useful for you as it saved you lots of memory.

 Thinking of what we should be able to do with decent classifier on the NIC's
 
 Would could probably determine if packet is for localhost and tag skb for all 
 sorts of new tricks. copy_threshhold is one and maybe even skip dst cache on big 
 routers etc.

 > Checking drivers/net/tg3.c, we can even see that in case of copying to a smaller skb,
 > we allocate it with a call to netdev_alloc_skb(), while it would be better
 > to use a plain alloc_skb() ...

 I'll let others comment this...

 Cheers.
						--ro

