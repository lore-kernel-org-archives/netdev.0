From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v5 12/16] net: sched: rcu'ify cls_bpf
Date: Fri, 12 Sep 2014 11:22:17 -0700
Message-ID: <1410546137.7106.100.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
	 <20140912163337.19588.52022.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37773 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbaILSWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 14:22:18 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so1822700pab.41
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 11:22:18 -0700 (PDT)
In-Reply-To: <20140912163337.19588.52022.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 09:33 -0700, John Fastabend wrote:
> This patch makes the cls_bpf classifier RCU safe. The tcf_lock
> was being used to protect a list of cls_bpf_prog now this list
> is RCU safe and updates occur with rcu_replace.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
