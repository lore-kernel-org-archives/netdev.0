From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access mc list V2
Date: Thu, 04 Feb 2010 10:22:34 -0800 (PST)
Message-ID: <20100204.102234.189055087.davem@davemloft.net>
References: <20100203125942.GA9266@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36205
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756302Ab0BDSWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 13:22:21 -0500
In-Reply-To: <20100203125942.GA9266@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 3 Feb 2010 13:59:43 +0100

> This patch introduces the similar helpers as those already done for uc list.
> However multicast lists are no list_head lists but "mademanually". The three
> macros added by this patch will make the transition of mc_list to list_head
> smooth in two steps:
> 
> 1) convert all drivers to use these macros (with the original iterator of type
>    "struct dev_mc_list")
> 2) once all drivers are converted, convert list type and iterators to "struct
>    netdev_hw_addr" in one patch.
> 
>>From now on, drivers can (and should) use "netdev_for_each_mc_addr" to iterate
> over the addresses with iterator of type "struct netdev_hw_addr". Also macros
> "netdev_mc_count" and "netdev_mc_empty" to read list's length. This is the state
> which should be reached in all drivers.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks Jiri.
