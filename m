From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] netlink: use blocking notifier
Date: Sat, 10 Dec 2016 17:26:34 -0500 (EST)
Message-ID: <20161210.172634.2066711201770725980.davem@davemloft.net>
References: <1481346661-25380-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58426 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752034AbcLJW0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 17:26:38 -0500
In-Reply-To: <1481346661-25380-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri,  9 Dec 2016 21:10:59 -0800

> netlink_chain is called in ->release(), which is apparently
> a process context, so we don't have to use an atomic notifier
> here.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
