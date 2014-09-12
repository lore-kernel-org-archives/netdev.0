From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v5 02/16] net: rcu-ify tcf_proto
Date: Fri, 12 Sep 2014 09:40:22 -0700
Message-ID: <1410540022.7106.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
	 <20140912162916.19588.13687.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:61794 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbaILQkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 12:40:24 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so1639075pad.7
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 09:40:23 -0700 (PDT)
In-Reply-To: <20140912162916.19588.13687.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 09:29 -0700, John Fastabend wrote:
> rcu'ify tcf_proto this allows calling tc_classify() without holding
> any locks. Updaters are protected by RTNL.
> 
> This patch prepares the core net_sched infrastracture for running
> the classifier/action chains without holding the qdisc lock however
> it does nothing to ensure cls_xxx and act_xxx types also work without
> locking. Additional patches are required to address the fall out.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks John !
