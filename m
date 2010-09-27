From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Sun, 26 Sep 2010 23:56:30 -0700 (PDT)
Message-ID: <20100926.235630.13733736.davem@davemloft.net>
References: <20100924063623.GA6359@ff.dom.local>
	<20100926.182208.102539866.davem@davemloft.net>
	<20100927053046.GA6296@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, eric.dumazet@gmail.com, socketcan@hartkopp.net,
	mst@redhat.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32795
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751374Ab0I0G4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 02:56:10 -0400
In-Reply-To: <20100927053046.GA6296@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 27 Sep 2010 05:30:47 +0000

> On Sun, Sep 26, 2010 at 06:22:08PM -0700, David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Fri, 24 Sep 2010 06:36:23 +0000
>> 
>> > af_packet could check some flag which guarantees the queued dev can do
>> > skb_orphan after the real xmit and copy buffers otherwise.
>> 
>> Jarek, we pre-orphan SKBs in the core way before device even gets
>> the packet.
> 
> I'm not sure which place in the core do you mean; skb_orphan_try() in
> dev_hard_start_xmit() depends on ->tx_flags.

Right, I keep forgetting about that special check, thanks for
reminding me :)
