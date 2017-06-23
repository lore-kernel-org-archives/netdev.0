From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] sit: use __GFP_NOWARN for user controlled
 allocation
Date: Fri, 23 Jun 2017 14:08:51 -0400 (EDT)
Message-ID: <20170623.140851.1003457505473145353.davem@davemloft.net>
References: <1498170573-24082-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34942 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752878AbdFWSIx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:08:53 -0400
In-Reply-To: <1498170573-24082-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 22 Jun 2017 15:29:33 -0700

> The memory allocation size is controlled by user-space,
> if it is too large just fail silently and return NULL,
> not to mention there is a fallback allocation later.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
