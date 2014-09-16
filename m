From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 4/4] net: sched: cls_fw: add missing
 tcf_exts_init call in fw_change()
Date: Tue, 16 Sep 2014 16:00:20 -0400 (EDT)
Message-ID: <20140916.160020.819013213102038048.davem@davemloft.net>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
	<20140916063141.2905.59421.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180AbaIPUAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:00:21 -0400
In-Reply-To: <20140916063141.2905.59421.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 15 Sep 2014 23:31:42 -0700

> When allocating a new structure we also need to call tcf_exts_init
> to initialize exts.
> 
> A follow up patch might be in order to remove some of this code
> and do tcf_exts_assign(). With this we could remove the
> tcf_exts_init/tcf_exts_change pattern for some of the classifiers.
> As part of the future tcf_actions RCU series this will need to be
> done. For now fix the call here.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
