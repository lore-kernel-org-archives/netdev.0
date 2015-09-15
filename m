From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 0/5] ipv6: Fix dst_entry refcnt bugs in
 ip6_tunnel
Date: Mon, 14 Sep 2015 19:49:25 -0700 (PDT)
Message-ID: <20150914.194925.1193918139295619388.davem@davemloft.net>
References: <1441994781-2718585-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbIOCt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 22:49:28 -0400
In-Reply-To: <1441994781-2718585-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 11 Sep 2015 11:06:16 -0700

> v3:
> - Merge a 'if else if' test in patch 4
> - Use rcu_dereference_protected in patch 5 to fix a sparse check when
>   CONFIG_SPARSE_RCU_POINTER is enabled
> 
> v2:
> - Add patch 4 and 5 to remove the spinlock
> 
> v1:
> This patch series is to fix the dst refcnt bugs in ip6_tunnel.
> 
> Patch 1 and 2 are the prep works.  Patch 3 is the fix.
> 
> I can reproduce the bug by adding and removing the ip6gre tunnel
> while running a super_netperf TCP_CRR test.  I get the following
> trace by adding WARN_ON_ONCE(newrefcnt < 0) to dst_release():
 ...

Series applied, thanks Martin.
