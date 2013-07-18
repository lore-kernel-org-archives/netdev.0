From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH BUGFIX] pkt_sched: sch_qfq: remove a source of high
 packet delay/jitter
Date: Thu, 18 Jul 2013 13:03:35 -0700 (PDT)
Message-ID: <20130718.130335.991768032324737210.davem@davemloft.net>
References: <1373911942.2062.24.camel@joe-AO722>
	<1373957550-10134-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fchecconi@gmail.com,
	rizzo@iet.unipi.it
To: paolo.valente@unimore.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965307Ab3GRUDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 16:03:38 -0400
In-Reply-To: <1373957550-10134-1-git-send-email-paolo.valente@unimore.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Valente <paolo.valente@unimore.it>
Date: Tue, 16 Jul 2013 08:52:30 +0200

 ...
> This patch addresses this issue by just using the above
> 'instantaneous' value of the weight sum, instead of the maximum
> possible value, when updating the system virtual time.  After the
> instantaneous weight sum is decreased, QFQ+ may deviate from the ideal
> service for a time interval in the order of the time to serve one
> maximum-size packet for each backlogged class. The worst-case extent
> of the deviation exhibited by QFQ+ during this time interval [1] is
> basically the same as of the deviation described above (but, without
> this patch, QFQ+ suffers from such a deviation all the time). Finally,
> this patch modifies the comment to the function qfq_slot_insert, to
> make it coherent with the fact that the weight sum used by QFQ+ can
> now be lower than the maximum possible value.
> 
> [1] P. Valente, "Extending WF2Q+ to support a dynamic traffic mix",
> Proceedings of AAA-IDEA'05, June 2005.
> 
> Signed-off-by: Paolo Valente <paolo.valente@unimore.it>

Thank you for this amazing commit message.

Since you explained everything, even if I don't understand all of the
details of QFQ/QFQ+ I can in fact be confident in your change.

Applied and queued up for -stable, thanks!
