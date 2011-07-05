From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 01:02:54 -0700 (PDT)
Message-ID: <20110705.010254.1376215864913143868.davem@davemloft.net>
References: <1309849214.2720.45.camel@edumazet-laptop>
	<20110705.005011.1268380726966376331.davem@davemloft.net>
	<4E12C2B2.9060007@inliniac.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754353Ab1GEIDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 04:03:01 -0400
In-Reply-To: <4E12C2B2.9060007@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Victor Julien <victor@inliniac.net>
Date: Tue, 05 Jul 2011 09:52:18 +0200

> On 07/05/2011 09:50 AM, David Miller wrote:
>> I will add an option to the fanout, as a flag bit to the setsockopt,
>> that will cause the fanout to act as a ip_defrag() agent and rehash
>> the packet once all the fragments arrive.
>> 
>> Since this will operate internally on the clones passed to AF_PACKET,
>> it will not have any effect on the original packets traversing through
>> the machine.
>> 
> 
> Does this mean the user space app gets a reassembled packet from the fan
> out?

Yes.

Would you prefer to receive the frags individually?

