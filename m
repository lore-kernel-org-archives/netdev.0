From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] kcm: return immediately after copy_from_user()
 failure
Date: Fri, 24 Mar 2017 13:14:37 -0700 (PDT)
Message-ID: <20170324.131437.338286643441645097.davem@davemloft.net>
References: <1490292211-19767-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966666AbdCXUOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:14:39 -0400
In-Reply-To: <1490292211-19767-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 23 Mar 2017 11:03:31 -0700

> There is no reason to continue after a copy_from_user()
> failure.
> 
> Fixes: ab7ac4eb9832 ("kcm: Kernel Connection Multiplexor module")
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable and this bug could make the kernel
use uninitialized on-stack data.
