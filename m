From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: move TC_PRIO_CONTROL check into
 ixgbe_select_queue()
Date: Sat, 27 Feb 2010 03:28:32 -0800 (PST)
Message-ID: <20100227.032832.54223147.davem@davemloft.net>
References: <20100227002135.32576.23757.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33101
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965891Ab0B0L2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 06:28:14 -0500
In-Reply-To: <20100227002135.32576.23757.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Feb 2010 16:21:36 -0800

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Move TC_PRIO_CONTROL check and queue remapping into
> ixgbe_select_queue().  Remapping queues after the qdisc
> can result in the wrong qdisc queue being stopped with
> netif_stop_subqueue().  Even if this is resolved and the
> correct queue is stopped it can result in a queue being
> blocked by TC_PRIO_CONTROL frames uneccesarily.  Moving
> this into the select_queue routine maintains alignment
> between tx_rings and qdisc queues.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
