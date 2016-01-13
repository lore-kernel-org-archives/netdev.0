From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 09/12] net: sched: pfifo_fast use alf_queue
Date: Wed, 13 Jan 2016 11:24:59 -0500 (EST)
Message-ID: <20160113.112459.133519495867760481.davem@davemloft.net>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
	<20151230175420.26257.868.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbcAMQZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 11:25:01 -0500
In-Reply-To: <20151230175420.26257.868.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 30 Dec 2015 09:54:20 -0800

> This also removes the logic used to pick the next band to dequeue
> from and instead just checks each alf_queue for packets from
> top priority to lowest. This might need to be a bit more clever
> but seems to work for now.

I suspect we won't need to be more clever, there's only 3 bands
after all and the head/tail tests should be fast enough.
