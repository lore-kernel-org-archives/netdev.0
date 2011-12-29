From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: use non-reentrant workqueue.
Date: Thu, 29 Dec 2011 16:44:58 -0500 (EST)
Message-ID: <20111229.164458.285201500999170488.davem@davemloft.net>
References: <87ehvogitg.fsf@rustcorp.com.au>
	<20111229203314.GB5051@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, tj@kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442Ab1L2VpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 16:45:05 -0500
In-Reply-To: <20111229203314.GB5051@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 29 Dec 2011 22:33:14 +0200

> On Thu, Dec 29, 2011 at 01:55:47PM +1030, Rusty Russell wrote:
>> Michael S. Tsirkin also noticed that we could run the refill work
>> multiple CPUs: if we kick off a refill on one CPU and then on another,
>> they would both manipulate the queue at the same time (they use
>> napi_disable to avoid racing against the receive handler itself).
>> 
>> Tejun points out that this is what the WQ_NON_REENTRANT flag is for,
>> and that there is a convenient system kthread we can use.
>> 
>> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
