From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: Fix a sleep-in-atomic bug
Date: Thu, 01 Jun 2017 14:50:13 -0400 (EDT)
Message-ID: <20170601.145013.397328786892049824.davem@davemloft.net>
References: <1496214505-15155-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, mingo@kernel.org, fweisbec@gmail.com,
        geliangtang@gmail.com, akpm@linux-foundation.org,
        yamada.masahiro@socionext.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: baijiaju1990@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58448 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdFASuQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 14:50:16 -0400
In-Reply-To: <1496214505-15155-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Wed, 31 May 2017 15:08:25 +0800

> The driver may sleep under a read spin lock, and the function call path is:
> send_socklist (acquire the lock by read_lock)
>   skb_copy(GFP_KERNEL) --> may sleep
> 
> To fix it, the "GFP_KERNEL" is replaced with "GFP_ATOMIC".
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Just proves that nobody has ever run this code with lock debugging
enabled, if at all.

Applied, thanks.
