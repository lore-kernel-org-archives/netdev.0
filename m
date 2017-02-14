From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] kcm: fix a null pointer dereference in
 kcm_sendmsg()
Date: Tue, 14 Feb 2017 13:07:12 -0500 (EST)
Message-ID: <20170214.130712.459629732733534046.davem@davemloft.net>
References: <1487013196-2375-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38844 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753183AbdBNSHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:07:14 -0500
In-Reply-To: <1487013196-2375-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 13 Feb 2017 11:13:16 -0800

> In commit 98e3862ca2b1 ("kcm: fix 0-length case for kcm_sendmsg()")
> I tried to avoid skb allocation for 0-length case, but missed
> a check for NULL pointer in the non EOR case.
> 
> Fixes: 98e3862ca2b1 ("kcm: fix 0-length case for kcm_sendmsg()")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
