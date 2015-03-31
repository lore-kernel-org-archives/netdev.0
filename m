From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] fib_trie: Fix warning on fib4_rules_exit
Date: Tue, 31 Mar 2015 13:19:12 -0400 (EDT)
Message-ID: <20150331.131912.139598313959999790.davem@davemloft.net>
References: <20150327211416.2465.23170.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbbCaRTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:19:14 -0400
In-Reply-To: <20150327211416.2465.23170.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 27 Mar 2015 14:14:16 -0700

> This fixes the following warning:
 ...
> The issue was that as a part of exiting the default rules were being
> deleted which resulted in the local trie being unmerged.  By moving the
> freeing of the FIB tables up we can avoid the unmerge since there is no
> local table left when we call the fib4_rules_exit function.
> 
> Fixes: 0ddcf43d5d4a ("ipv4: FIB Local/MAIN table collapse")
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied.
