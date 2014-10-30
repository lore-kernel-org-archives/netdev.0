From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/2] sunvnet: Use multiple Tx queues.
Date: Thu, 30 Oct 2014 19:57:00 -0400 (EDT)
Message-ID: <20141030.195700.1439580436793637431.davem@davemloft.net>
References: <20141030164547.GE650@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161210AbaJ3X5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:57:02 -0400
In-Reply-To: <20141030164547.GE650@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 30 Oct 2014 12:45:47 -0400

> 
> v2: moved tcp fix out of this series per David Miller feedback
> 
> The primary objective of this patch-set is to address the suggestion from
>   http://marc.info/?l=linux-netdev&m=140790778931563&w=2
> With the changes in Patch 2, every vnet_port will get  packets from 
> a single tx-queue, and flow-control/head-of-line-blocking is 
> confined to the vnet_ports that share that tx queue (as opposed to 
> flow-controlling *all* peers).
> 
> Patch 1 is an optimization that resets the DATA_READY bit when
> we re-enable Rx interrupts.  This optimization lets us exit quickly 
> from vnet_event_napi() when new data has not triggered an interrupt.

This looks great, series applied to net-next, thanks.
