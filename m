From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net 0/5] ipv6: Fix dst_entry refcnt bugs in
 ip6_tunnel
Date: Tue, 15 Sep 2015 15:02:52 -0700 (PDT)
Message-ID: <20150915.150252.882663449854060859.davem@davemloft.net>
References: <1442352609-1476011-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbIOWCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 18:02:53 -0400
In-Reply-To: <1442352609-1476011-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 15 Sep 2015 14:30:04 -0700

> v4:
> - Fix a compilation error in patch 5 when CONFIG_LOCKDEP is turned on and
>   re-test it
> 
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

Series applied, thanks.
