From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/packet: check length in getsockopt() called with
 PACKET_HDRLEN
Date: Tue, 25 Apr 2017 14:06:04 -0400 (EDT)
Message-ID: <20170425.140604.276789553615920800.davem@davemloft.net>
References: <20170425165146.25075-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1432573AbdDYSGG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 14:06:06 -0400
In-Reply-To: <20170425165146.25075-1-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Potapenko <glider@google.com>
Date: Tue, 25 Apr 2017 18:51:46 +0200

> In the case getsockopt() is called with PACKET_HDRLEN and optlen < 4
> |val| remains uninitialized and the syscall may behave differently
> depending on its value, and even copy garbage to userspace on certain
> architectures. To fix this we now return -EINVAL if optlen is too small.
> 
> This bug has been detected with KMSAN.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Applied, thanks.
