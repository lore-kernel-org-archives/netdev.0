From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 1/2] net: cls_u32: fix missed pcpu_success
 free_percpu
Date: Mon, 22 Sep 2014 15:59:43 -0400 (EDT)
Message-ID: <20140922.155943.695471801124269403.davem@davemloft.net>
References: <20140920045003.9869.16851.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416AbaIVT77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:59:59 -0400
In-Reply-To: <20140920045003.9869.16851.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 19 Sep 2014 21:50:04 -0700

> This fixes a missed free_percpu in the unwind code path and when
> keys are destroyed.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
