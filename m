From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 08/16] net: sched: RCU cls_tcindex
Date: Wed, 10 Sep 2014 18:17:31 -0700
Message-ID: <1410398251.7106.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910154959.2036.57657.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36690 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbaIKBRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 21:17:33 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so6646192pdb.28
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 18:17:33 -0700 (PDT)
In-Reply-To: <20140910154959.2036.57657.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:50 -0700, John Fastabend wrote:
> Make cls_tcindex RCU safe.
> 
> This patch addds a new RCU routine rcu_dereference_bh_rtnl() to check
> caller either holds the rcu read lock or RTNL. This is needed to
> handle the case where tcindex_lookup() is being called in both cases.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
