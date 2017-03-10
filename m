From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: initialize msg.msg_flags in recvfrom
Date: Thu, 09 Mar 2017 17:21:53 -0800 (PST)
Message-ID: <20170309.172153.1200371456941480294.davem@davemloft.net>
References: <20170308170816.8533-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: glider@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754468AbdCJBXQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 20:23:16 -0500
In-Reply-To: <20170308170816.8533-1-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Potapenko <glider@google.com>
Date: Wed,  8 Mar 2017 18:08:16 +0100

> KMSAN reports a use of uninitialized memory in put_cmsg() because
> msg.msg_flags in recvfrom haven't been initialized properly.
> The flag values don't affect the result on this path, but it's still a
> good idea to initialize them explicitly.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> Changes since v1:
>  - removed KMSAN report and reproducer from the description

Applied, thank you.
