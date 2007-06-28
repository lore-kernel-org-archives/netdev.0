From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware
 support API
Date: Thu, 28 Jun 2007 18:31:24 +0200
Message-ID: <4683E25C.5020303@trash.net>
References: <20070628162056.18728.20195.stgit@localhost.localdomain> <20070628162113.18728.20109.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54502 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191AbXF1Qc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:32:56 -0400
In-Reply-To: <20070628162113.18728.20109.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> Updated: Fixed allocation of subqueues in alloc_netdev_mq() to
> allocate all subqueues, not num - 1.
>
> Added checks for netif_subqueue_stopped() to netpoll,
> pktgen, and software device dev_queue_xmit().  This will ensure
> external events to these subsystems will be handled correctly if
> a subqueue is shut down.
>
> Add the multiqueue hardware device support API to the core network
> stack.  Allow drivers to allocate multiple queues and manage them
> at the netdev level if they choose to do so.
>
> Added a new field to sk_buff, namely queue_mapping, for drivers to
> know which tx_ring to select based on OS classification of the flow.
>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>   

Acked-by: Patrick McHardy <kaber@trash.net>

skb->iif and queue_mapping should probably go somewhere near
the other shaping stuff and unsigned int seems to be a better
choice for egress_subqueue_count, but I can take care of that
when this patch is in Dave's tree.




