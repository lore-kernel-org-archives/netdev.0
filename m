From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] i40e: skb->xmit_more support
Date: Wed, 08 Oct 2014 13:35:09 -0400 (EDT)
Message-ID: <20141008.133509.184049487346908540.davem@davemloft.net>
References: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141008100258.00006afd@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dborkman@redhat.com, jeffrey.t.kirsher@intel.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbaJHRfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 13:35:12 -0400
In-Reply-To: <20141008100258.00006afd@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Wed, 8 Oct 2014 10:02:58 -0700

> On Tue, 7 Oct 2014 13:30:23 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Support skb->xmit_more in i40e is straightforward : we need to move
>> around i40e_maybe_stop_tx() call to correctly test
>> netif_xmit_stopped() before taking the decision to not kick the NIC.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Looks good to me.

Jeff, ok for me to apply this directly now?

Thanks.
