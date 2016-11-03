From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] genetlink: fix a memory leak on error path
Date: Thu, 03 Nov 2016 16:53:57 -0400 (EDT)
Message-ID: <20161103.165357.1889984861158784546.davem@davemloft.net>
References: <1478191356-10386-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kubakici@wp.pl, johannes@sipsolutions.net
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757998AbcKCUx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:53:59 -0400
In-Reply-To: <1478191356-10386-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu,  3 Nov 2016 09:42:35 -0700

> In __genl_register_family(), when genl_validate_assign_mc_groups()
> fails, we forget to free the memory we possibly allocate for
> family->attrbuf.
> 
> Note, some callers call genl_unregister_family() to clean up
> on error path, it doesn't work because the family is inserted
> to the global list in the nearly last step.
> 
> Cc: Jakub Kicinski <kubakici@wp.pl>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks Cong.
