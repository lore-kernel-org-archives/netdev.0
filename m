From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 07/16] net: sched: RCU cls_route
Date: Wed, 10 Sep 2014 18:12:05 -0700
Message-ID: <1410397925.7106.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910154930.2036.78269.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34689 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbaIKBMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 21:12:07 -0400
Received: by mail-pd0-f173.google.com with SMTP id ft15so10162063pdb.18
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 18:12:07 -0700 (PDT)
In-Reply-To: <20140910154930.2036.78269.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:49 -0700, John Fastabend wrote:
> RCUify the route classifier. For now however spinlock's are used to
> protect fastmap cache.
> 
> The issue here is the fastmap may be read by one CPU while the
> cache is being updated by another. An array of pointers could be
> one possible solution.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
