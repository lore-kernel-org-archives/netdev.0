From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Wed, 08 May 2013 13:16:08 -0700 (PDT)
Message-ID: <20130508.131608.2126756346585157464.davem@davemloft.net>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com,
	yoshfuji@linux-ipv6.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab3EHUQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 16:16:09 -0400
In-Reply-To: <1367998914-26423-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed,  8 May 2013 15:41:54 +0800

> dingtianhong reported the following deadlock detected by lockdep:
 ...
> Reported-by: dingtianhong <dingtianhong@huawei.com>
> Cc: dingtianhong <dingtianhong@huawei.com>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

I'm waiting for testing validation of this patch.
