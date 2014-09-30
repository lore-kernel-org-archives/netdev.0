From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Tue, 30 Sep 2014 14:20:38 -0400 (EDT)
Message-ID: <20140930.142038.235338672810639160.davem@davemloft.net>
References: <20140930085114.24043.81310.stgit@dragon>
	<542A8EF9.10403@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	eric.dumazet@gmail.com, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbaI3SUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 14:20:41 -0400
In-Reply-To: <542A8EF9.10403@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue, 30 Sep 2014 07:07:37 -0400

> Note, there are benefits as you have shown - but i would not
> consider those to be standard use cases (actully one which would
> have shown clear win is the VM thing Rusty was after).

I completely disagree, you will see at least decreased cpu utilization
for a very common case, bulk single stream transfers.

> For this reason my view is that i should be able to disable via
> ifdef bulking (yes, I know DaveM hates ifdefs ;->).

Vehemntly _disagree_. :)
